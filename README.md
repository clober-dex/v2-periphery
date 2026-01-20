# Clober V2 Periphery

[![Docs](https://img.shields.io/badge/docs-%F0%9F%93%84-blue)](https://docs.clober.io/)
[![CI status](https://github.com/clober-dex/v2-periphery/actions/workflows/test.yaml/badge.svg)](https://github.com/clober-dex/v2-periphery/actions/workflows/test.yaml)
[![Discord](https://img.shields.io/static/v1?logo=discord&label=discord&message=Join&color=blue)](https://discord.com/invite/clober-coupon-finance)
[![Twitter](https://img.shields.io/static/v1?logo=twitter&label=twitter&message=Follow&color=blue)](https://twitter.com/CloberDEX)

Periphery Contract of Clober DEX V2

## Table of Contents

- [Clober V2 Periphery](#clober-v2-periphery)
    - [Table of Contents](#table-of-contents)
    - [Deployments](#deployments)
    - [Install](#install)
    - [Usage](#usage)
        - [Tests](#tests)
        - [Formatting](#formatting)

## Deployments

> Note: `BookViewer` is deployed behind an ERC1967 proxy. The address below is the **proxy address**.

| Network | Chain ID | Controller | BookViewer |
| --- | ---: | --- | --- |
| Base | 8453 | [`0x2610dc1f2e625e57f07b0ce17152b0f4c6520bca`](https://basescan.org/address/0x2610dc1f2e625e57f07b0ce17152b0f4c6520bca) | [`0xcd166f67f13c7d5c4b899fb1c980dceff278f029`](https://basescan.org/address/0xcd166f67f13c7d5c4b899fb1c980dceff278f029) |
| Arbitrum One | 42161 | [`0x53691300635ce3ae575f91a186c2248a0e159830`](https://arbiscan.io/address/0x53691300635ce3ae575f91a186c2248a0e159830) | [`0xc6ed4be4a69fd23eb6ab9c6f8b787748def2362e`](https://arbiscan.io/address/0xc6ed4be4a69fd23eb6ab9c6f8b787748def2362e) |
| Monad | 143 | [`0x19b68a2b909D96c05B623050C276FBD457De8e83`](https://monadvision.com/address/0x19b68a2b909D96c05B623050C276FBD457De8e83) | [`0xe424c211e2Ed8a5B6d1C57FA493C41715568D238`](https://monadvision.com/address/0xe424c211e2Ed8a5B6d1C57FA493C41715568D238) |

## Install


### Prerequisites
- We use [Foundry](https://github.com/foundry-rs/foundry). Follow the [installation guide](https://github.com/foundry-rs/foundry#installation).

### Installing From Source

```bash
git clone https://github.com/clober-dex/v2-periphery && cd v2-periphery
git submodule update --init --recursive
forge install
```

## Usage

### Tests
```bash
forge test
```

### Formatting

```bash
forge fmt --check
```

To format files:
```bash
forge fmt
```
