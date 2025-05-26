use core::{f32::consts::TAU, u8, u16};
use micromath::F32Ext;

use embassy_time::{Duration, Instant, Timer};
use esp_alloc as _;
use esp_backtrace as _;
use esp_hal::{self, gpio::AnyPin, peripherals::RMT, rmt::Rmt};
use esp_hal_smartled::SmartLedsAdapter;
use fugit::RateExtU32;
use smart_leds::SmartLedsWrite;
use smart_leds::{
    RGB8,
    hsv::{Hsv, hsv2rgb},
};

const PIXELS: usize = 10;

trait Animator<const PIXELS: usize> {
    fn next(&mut self) -> [RGB8; PIXELS];
}

struct Chase {
    position: u16,
    speed: Duration,
    color: RGB8,
}

struct Pulse {
    color: Hsv,
    speed: Duration,
    start: Option<Instant>,
}

impl Default for Pulse {
    fn default() -> Self {
        Self {
            color: Hsv {
                hue: 0,
                sat: 255,
                val: 255,
            },
            speed: Duration::from_secs(4),
            start: None,
        }
    }
}

fn pulse<const PIXELS: usize>(color: Hsv, phase: f32) -> [RGB8; PIXELS] {
    let mut color = color.clone();
    unsafe {
        color.val = (f32::from(color.val) * (phase.cos() + 1.0) / 2f32).to_int_unchecked();
    }
    [hsv2rgb(color); PIXELS]
}

#[embassy_executor::task]
async fn led_animator(rmt: RMT, pin: AnyPin) {
    let freq = 80u32.MHz();
    let rmt = Rmt::new(rmt, freq).unwrap();
    let rmt_buffer = [0u32; PIXELS * 24 + 1];
    let mut led = SmartLedsAdapter::new(rmt.channel0, pin, rmt_buffer);
    let mut start = Instant::now();
    let speed = Duration::from_secs(3);
    loop {
        let now = Instant::now();
        if start + speed < now {
            // We've completed a cycle, start again
            start = now;
        }
        let phase: f32 = ((now - start).as_millis() as f32 * TAU) / speed.as_millis() as f32;
        led.write(pulse::<PIXELS>(
            Hsv {
                hue: ((phase / TAU) * u8::MAX as f32) as u8,
                sat: 255,
                val: 255,
            },
            phase,
        ))
        .unwrap();
        Timer::after(Duration::from_millis(20)).await;
    }
}
