#![feature(generic_arg_infer)]
#![feature(generic_const_exprs)]
#![no_std]
#![no_main]

mod ksz8851snl;
mod leds;
mod rpc;
mod tally;

use core::u8;
use defmt::info;
use embassy_futures::select::{Either, select};
use embedded_hal_bus::spi::ExclusiveDevice;
use ksz8851snl::State;

use embassy_executor::Spawner;
use embassy_net::{
    Runner, StackResources,
    udp::{PacketMetadata, UdpSocket},
};
use embassy_time::{Delay, Duration, Timer};
use esp_alloc as _;
use esp_backtrace as _;
use esp_hal::{
    self, Async,
    clock::CpuClock,
    efuse::Efuse,
    gpio::{Input, Level, Output, Pull},
    rng::Rng,
    spi::master::{Config, Spi},
    timer::{systimer::SystemTimer, timg::TimerGroup},
};
use esp_hal_embassy::main;
use esp_println::println;
use esp_wifi::{
    EspWifiController, init,
    wifi::{
        ClientConfiguration, Configuration, WifiController, WifiDevice, WifiEvent, WifiStaDevice,
        WifiState,
    },
};
use fugit::RateExtU32;
use smart_leds::SmartLedsWrite;
use static_cell::StaticCell;

macro_rules! mk_static {
    ($t:ty,$val:expr) => {{
        static STATIC_CELL: static_cell::StaticCell<$t> = static_cell::StaticCell::new();
        #[deny(unused_attributes)]
        let x = STATIC_CELL.uninit().write(($val));
        x
    }};
}

const SSID: &str = env!("SSID");
const PASSWORD: &str = env!("PASSWORD");

#[main]
async fn main(spawner: Spawner) {
    esp_println::logger::init_logger_from_env();

    let mut config = esp_hal::Config::default();
    config.cpu_clock = CpuClock::max();
    let peripherals = esp_hal::init(config);

    esp_alloc::heap_allocator!(72 * 1024);

    let timg0 = TimerGroup::new(peripherals.TIMG0);
    let mut rng = Rng::new(peripherals.RNG);

    let init = &*mk_static!(
        EspWifiController<'static>,
        init(timg0.timer0, rng.clone(), peripherals.RADIO_CLK).unwrap()
    );

    let wifi = peripherals.WIFI;
    let (wifi_interface, controller) =
        esp_wifi::wifi::new_with_mode(&init, wifi, WifiStaDevice).unwrap();

    let systimer = SystemTimer::new(peripherals.SYSTIMER);
    esp_hal_embassy::init(systimer.alarm0);

    let config = embassy_net::Config::dhcpv4(Default::default());

    let seed = (rng.random() as u64) << 32 | rng.random() as u64;
    // Init network stack
    let (stack, runner) = embassy_net::new(
        wifi_interface,
        config.clone(),
        mk_static!(StackResources<3>, StackResources::<3>::new()),
        seed,
    );

    //spawner.spawn(connection(controller)).ok();
    //spawner.spawn(wifi_runner_task(runner)).ok();

    // spawner
    //     .spawn(led_animator(peripherals.RMT, peripherals.GPIO6.into()))
    //     .ok();
    //
    //loop {
    //    Timer::after_millis(50).await;
    //}

    // Ethernet
    let eth_reset = Output::new(peripherals.GPIO10, Level::Low);
    let eth_int = Input::new(peripherals.GPIO7, Pull::None);
    let spi: Spi<'static, _> = Spi::new(
        peripherals.SPI2,
        Config::default()
            .with_frequency(1.MHz())
            .with_mode(esp_hal::spi::Mode::_0),
    )
    .unwrap()
    .with_sck(peripherals.GPIO1)
    .with_miso(peripherals.GPIO3)
    .with_mosi(peripherals.GPIO8)
    .into_async();

    let cs = Output::new(peripherals.GPIO2, Level::Low);

    let spi = ExclusiveDevice::new(spi, cs, Delay).unwrap();

    // Read the wifi mac and use it for ethernet.
    // This is a little bit dodgy, but so long as we ensure only one of ethernet/wifi are in use...
    let mac = Efuse::read_base_mac_address();

    static STATE: StaticCell<State<10, 10>> = StaticCell::new();
    let state = STATE.init(State::<10, 10>::new());
    let (netdev, netrunner) = ksz8851snl::new(mac, state, spi, eth_int, eth_reset)
        .await
        .unwrap();
    spawner.spawn(eth_driver_runner_task(netrunner)).unwrap();
    let (eth_stack, eth_runner) = embassy_net::new(
        netdev,
        config,
        mk_static!(StackResources<3>, StackResources::<3>::new()),
        seed,
    );
    spawner.spawn(eth_runner_task(eth_runner)).unwrap();

    let (mut tx_buf, mut rx_buf) = ([0u8; 128], [0u8; 128]);
    let mut rx_meta = [PacketMetadata::EMPTY; 16];
    let mut tx_meta = [PacketMetadata::EMPTY; 16];
    let mut sock = UdpSocket::new(
        eth_stack,
        &mut rx_meta,
        &mut rx_buf,
        &mut tx_meta,
        &mut tx_buf,
    );
    sock.bind(1234).unwrap();
    let mut udpbuf = [0u8; 1024];
    loop {
        defmt::info!("Waiting for ethernet link up...");
        eth_stack.wait_link_up().await;
        defmt::info!("Link up!");
        defmt::info!("Wating for dhcp...");
        eth_stack.wait_config_up().await;
        if let Some(c) = eth_stack.config_v4() {
            defmt::info!("DHCP: {}", c.address);
        }
        loop {
            match select(eth_stack.wait_link_down(), sock.recv_from(&mut udpbuf)).await {
                Either::First(_) => {
                    defmt::info!("Link down");
                    break;
                }
                Either::Second(Ok((len, meta))) => {
                    info!("{} bytes from {}", len, meta);
                    sock.send_to(&udpbuf[..len], meta.endpoint).await.unwrap();
                }
                Either::Second(_) => panic!(),
            }
        }
    }
}

#[embassy_executor::task]
async fn wifi_runner_task(mut runner: Runner<'static, WifiDevice<'static, WifiStaDevice>>) {
    runner.run().await
}

#[embassy_executor::task]
async fn eth_runner_task(
    mut runner: Runner<'static, embassy_net_driver_channel::Device<'static, 1514>>,
) {
    runner.run().await
}

#[embassy_executor::task]
async fn eth_driver_runner_task(
    r: ksz8851snl::Runner<
        'static,
        ExclusiveDevice<Spi<'static, Async>, Output<'static>, Delay>,
        Input<'static>,
        Output<'static>,
    >,
) {
    r.run().await
}

#[embassy_executor::task]
async fn connection(mut controller: WifiController<'static>) {
    println!("start connection task");
    println!("Device capabilities: {:?}", controller.capabilities());
    loop {
        match esp_wifi::wifi::wifi_state() {
            WifiState::StaConnected => {
                // wait until we're no longer connected
                controller.wait_for_event(WifiEvent::StaDisconnected).await;
                Timer::after(Duration::from_millis(5000)).await
            }
            _ => {}
        }
        if !matches!(controller.is_started(), Ok(true)) {
            let client_config = Configuration::Client(ClientConfiguration {
                ssid: SSID.try_into().unwrap(),
                password: PASSWORD.try_into().unwrap(),
                ..Default::default()
            });
            controller.set_configuration(&client_config).unwrap();
            println!("Starting wifi");
            controller.start_async().await.unwrap();
            println!("Wifi started!");
        }
        println!("About to connect...");

        match controller.connect_async().await {
            Ok(_) => println!("Wifi connected!"),
            Err(e) => {
                println!("Failed to connect to wifi: {e:?}");
                Timer::after(Duration::from_millis(5000)).await
            }
        }
    }
}
