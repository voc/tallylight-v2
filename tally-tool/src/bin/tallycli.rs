use std::net::Ipv4Addr;

use postcard_rpc::host_client::HostClient;
use std::net::ToSocketAddrs;
use tally_rpc::rpc::{InfoEndpoint, InfoResponse, WireErr};

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let addr = (Ipv4Addr::new(10, 11, 12, 13), 1234)
        .to_socket_addrs()
        .unwrap()
        .next()
        .unwrap();
    let cli = HostClient::<postcard_rpc::standard_icd::WireError>::connect_tcp(addr).await;
    println!("connected");
    let info: InfoResponse = cli.send_resp::<InfoEndpoint>(&()).await.unwrap();
    println!("{:?}", info);
}
