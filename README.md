## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/SimpleNFT_OpenZeppelin.s.sol:SimpleNFT_OpenZeppelinScript --account main --sender <PUBLIC ADDRESS RELATED TO --account> --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

```shell
forge create src/SimpleNFT_OpenZeppelin.sol:SimpleNFT_OpenZeppelin --constructor-args "NFTtest" "NFTt" --account main --rpc-url $SEPOLIA_RPC_URL  --verify
```

Deploying on Scroll Sepolia testnet:

```shell
forge script script/SimpleNFT_OpenZeppelin.s.sol:SimpleNFT_OpenZeppelinScript --account main --sender <PUBLIC ADDRESS RELATED TO --account> --rpc-url $SEPOLIA_SCROLL_RPC_URL --legacy --broadcast -vvvvv
```

Verify on scroll testnet:

    not working waiting on scroll to get an update about it but this should work soon

    could work on other network with proper parameters

```shell
forge verify-contract <CONTRACT ADDRESS> --constructor-args $(cast abi-encode "constructor(string,string)" "NFT_test" "test") --watch src/SimpleNFT_OpenZeppelin.sol:SimpleNFT_OpenZeppelin --compiler-version v0.8.21+commit.d9974bed --chain-id 534351 --verifier-url $SEPOLIA_SCROLL_VERIFY_URL --verifier blockscout
```

### Keystore

```shell
cast wallet import your-account-name --interactive or --private-key or --mnemonic-path
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
