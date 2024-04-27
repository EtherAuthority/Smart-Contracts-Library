# MultiSign Wallet

## Contract Addresses

- **MultiSign Wallet Contract**: [0xCE1c931403836f15eFeA2c22dA13860B584d73B1](https://testnet.bscscan.com/address/0xCE1c931403836f15eFeA2c22dA13860B584d73B1#code)
- **Validators Contract**: [0xFA575e4C89D8A1d68F8637C8ee8eaa1B7830f596](https://testnet.bscscan.com/address/0xFA575e4C89D8A1d68F8637C8ee8eaa1B7830f596)

## Test Cases

### 1. New Contract Ownership Transfer

- Transfer ownership to validator contract to multisign contract: [Transaction](https://testnet.bscscan.com/tx/0x7030b29cbd71d751edb76cb96602fe9664fcbc5115e45d84a230fb6b6a7439b1)

### 2. Old Contract Ownership Transfer to a Contract Address

- Transfer ownership to validator contract to multisign contract: [Transaction](https://testnet.bscscan.com/tx/0x7030b29cbd71d751edb76cb96602fe9664fcbc5115e45d84a230fb6b6a7439b1)

### 3. Old Contract Ownership Transfer Contract to Wallet Address

1. Generate transaction for transferOwnership (trns id is 2): [Transaction](https://testnet.bscscan.com/tx/0x6d90f62b8f4148080bf2d74bc4bdd8e903d7997bce6026203a1f7598ef8fa56a)
2. Approve transaction: [Transaction](https://testnet.bscscan.com/tx/0x3602bea1be85fedad37f4323f6d6b0e6d40a2086b158a4f1b8970b720e649e1d)
3. Approve transaction and set new value: [Transaction](https://testnet.bscscan.com/tx/0xc70b8c85a0dc39080cc62c54e77624a58fa2b7eacaa217dca41d26b3b4e21964)

### 4. Check Gas Fee Function Using New Contract

1. Generate transaction for updateGasSettings (trns id is 0): [Transaction](https://testnet.bscscan.com/tx/0x92fba458d837e777d961d01e0ce3e1b38ecce5457af8b8613334dd646d6d699b)
2. Approve transaction: [Transaction](https://testnet.bscscan.com/tx/0xd0f30836c05901bd8e784cd268dc0300486a79302433b94980f1194754fec127)
3. Approve transaction and set new value: [Transaction](https://testnet.bscscan.com/tx/0xc60ca907c91acffb4fa7e994935c421b18ea740ba71d84186e35a09c78cf81cc)

### 5. Check Param Function Using New Contract

1. Generate transaction for updateParams (trns id is 1): [Transaction](https://testnet.bscscan.com/tx/0x135cbff02d15b8355f09d82909c32b58cb92178d5c5f0a02b1cb50a5f1245f13)
2. Approve transaction: [Transaction](https://testnet.bscscan.com/tx/0xbc411c76a1b70354b0a4fbcd08838481503599573b679e6ac95cf950b92307aa)
3. Approve transaction and set new value: [Transaction](https://testnet.bscscan.com/tx/0x9309bc9cc8df2629cbdcec6577142db41e9b884c2cc3b2faeff088612946a460)

### 6. Check Renounce Ownership Using New Contract

1. Generate transaction for renounceOwnership (trns id is 3): [Transaction](https://testnet.bscscan.com/tx/0xc891cd4ce0f5b12995dfa84e8b9dfe87846b0672d234550eea41975f22994ed5)
2. Approve transaction: [Transaction](https://testnet.bscscan.com/tx/0x69523f045dac79538e8da91750cd10c22202f8d6a54b5568e600404115432ed7)
3. Approve transaction and set new value: [Transaction](https://testnet.bscscan.com/tx/0xdf14330b4ecfc176341665cbaccb6cca1a8b9b673b5421ae84e4a283cb6f6546)
