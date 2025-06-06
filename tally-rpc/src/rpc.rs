use heapless::Vec;
use postcard_rpc::{TopicDirection, endpoints, topics};
use postcard_schema::Schema;
use serde::{Deserialize, Serialize};

endpoints! {
    list = ENDPOINTS_LIST;
    | EndpointTy            | RequestTy     | ResponseTy        | Path         |
    | ----------            | ---------     | ----------        | ----         |
    | InfoEndpoint          | ()            | InfoResponse<'a>  | "info"       |
    | SetConfigEndpoint     | Config        | ()                | "setconf"    |
    | StartColorTest        | ()            | bool              | "startcolor" |
    | StopColorTest         | ()            | bool              | "stopcolor"  |
}

topics! {
    list = TOPICS_IN_LIST;
    direction = TopicDirection::ToServer;
    | TopicTy                   | MessageTy     | Path              |
    | -------                   | ---------     | ----              |
    | ColorTestTopic            | ColorTest     | "colortest"       |
}

topics! {
    list = TOPICS_OUT_LIST;
    direction = TopicDirection::ToClient;
    | TopicTy                   | MessageTy     | Path              | Cfg                           |
    | -------                   | ---------     | ----              | ---                           |
}

#[derive(Deserialize, Serialize, Schema, Debug)]
pub enum WireErr {}

// Requests

#[derive(Serialize, Deserialize, Schema, Debug)]
pub enum IfaceConfig {
    Static { ip: [u8; 4], mask: u8 },
    DHCP,
}

impl From<IfaceConfig> for embassy_net::Config {
    fn from(value: IfaceConfig) -> Self {
        match value {
            IfaceConfig::Static { ip, mask } => {
                embassy_net::Config::ipv4_static(embassy_net::StaticConfigV4 {
                    address: embassy_net::Ipv4Cidr::new(ip.into(), mask),
                    gateway: None,
                    dns_servers: Vec::new(),
                })
            }
            IfaceConfig::DHCP => embassy_net::Config::dhcpv4(Default::default()),
        }
    }
}

#[derive(Serialize, Deserialize, Schema, Debug)]
pub struct Config {
    //name: &'a str,
    pub eth: IfaceConfig,
    pub eth_leds: bool,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            eth: IfaceConfig::DHCP,
            eth_leds: true,
        }
    }
}

// Responses

#[derive(Serialize, Deserialize, Schema, Debug)]
pub struct InfoResponse<'a> {
    pub name: &'a str,
    pub mac: [u8; 6],
    pub fw_version: (u8, u8, u8),
}

#[derive(Serialize, Deserialize, Schema, Debug)]
pub struct Color {
    r: u8,
    g: u8,
    b: u8,
}

// Topics
#[derive(Serialize, Deserialize, Schema, Debug)]
pub struct ColorTest {
    color: Color,
    angle: u8,
    width: u8,
}
