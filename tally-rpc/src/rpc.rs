use postcard_rpc::{endpoints, topics, TopicDirection};
use postcard_schema::Schema;
use serde::{Deserialize, Serialize};

endpoints! {
    list = ENDPOINTS_LIST;
    | EndpointTy            | RequestTy     | ResponseTy    | Path      |
    | ----------            | ---------     | ----------    | ----      |
    | InfoEndpoint          | ()            | InfoResponse  | "info"    |
}

topics! {
    list = TOPICS_IN_LIST;
    direction = TopicDirection::ToServer;
    | TopicTy                   | MessageTy     | Path              |
    | -------                   | ---------     | ----              |
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

// Responses

#[derive(Serialize, Deserialize, Schema, Debug)]
pub struct InfoResponse {
    pub mac: [u8; 6],
    pub fw_version: (u8, u8, u8),
}

#[derive(Serialize, Deserialize)]
pub struct EthConfig {}

#[derive(Serialize, Deserialize)]
pub struct Config<'a> {
    name: &'a str,
    eth: EthConfig,
}
