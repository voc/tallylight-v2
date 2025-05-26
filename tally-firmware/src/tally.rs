use bondrewd::Bitfields;

#[derive(Bitfields, Debug, PartialEq, Eq)]
#[bondrewd(enforce_bytes = 18)]
struct TSL31Message {
    #[bondrewd(bit_length = 1)]
    __: bool,
    #[bondrewd(bit_length = 7)]
    address: u8,
    tally_1: bool,
    tally_2: bool,
    tally_3: bool,
    tally_4: bool,
    #[bondrewd(bit_length = 2)]
    brightness: u8,
    #[bondrewd(bit_length = 2)]
    ___: u8,
    #[bondrewd(endianness = "be")]
    data: [u8; 16],
}

#[cfg(test)]
mod tests {
    use super::*;

    // #[test]
    // fn test_tsl_decode() {
    //     assert_eq!(
    //         TSL31Message::from_bytes(&[0x81u8, 0b0011_0001, 'h' as u8, 'e', 'l', 'l', 'o', '\0' ]),
    //         TSL31Message {
    //             __: true,
    //             ___: 0,
    //             address: 1,
    //             tally_1: true,
    //             tally_2: false,
    //             tally_3: false,
    //             tally_4: false,
    //             brightness:3,
    //             data: [0; 16],
    //         }
    //     );
    // }
}
