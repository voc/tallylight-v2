use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Info {
    mac: [u8; 6],
    fw_version: (u8, u8, u8),
}

#[derive(Serialize, Deserialize)]
pub struct EthConfig {}

#[derive(Serialize, Deserialize)]
pub struct Config<'a> {
    name: &'a str,
    eth: EthConfig,
}
