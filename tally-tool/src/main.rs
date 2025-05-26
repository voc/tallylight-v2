use postcard_rpc::host_client::HostClient;
use tally_rpc::rpc;

#[tokio::main]
async fn main() {
    let cli =
        HostClient::<rpc::WireErr>::connect_tcp(std::env::args().skip(1).take(1).next().unwrap());
    let info = cli.await.send_resp::<rpc::InfoEndpoint>(&()).await.unwrap();
    println!("{:?}", info);
}
