import {
  arbitrum,
  arbitrumSepolia,
  base,
  berachainTestnetbArtio,
  monadTestnet,
  sepolia,
  zkSync,
  zkSyncSepoliaTestnet,
} from 'viem/chains'
import { Address } from 'viem'
import { monadPrivateMainnet, riseTestnet } from './chains'

export const BOOK_MANAGER: { [chainId: number]: Address } = {
  [sepolia.id]: '0xAA9575d63dFC224b9583fC303dB3188C08d5C85A',
  [arbitrumSepolia.id]: '0xAA9575d63dFC224b9583fC303dB3188C08d5C85A',
  [base.id]: '0x382CCccbD3b142D7DA063bF68cd0c89634767F76',
  [berachainTestnetbArtio.id]: '0x874b1B795993653fbFC3f1c1fc0469214cC9F4A5',
  [zkSyncSepoliaTestnet.id]: '0x76F479c6ae5Cdd3180C9cAa09bEefeBC78fdB931',
  [zkSync.id]: '0xAc6AdB2727F99C309acd511D942c0b2812e03614',
  [monadTestnet.id]: '0xAA9575d63dFC224b9583fC303dB3188C08d5C85A',
  [riseTestnet.id]: '0xBc6eaFe723723DED3a411b6a1089a63bc5d73568',
  [monadPrivateMainnet.id]: '0x6657d192273731C3cAc646cc82D5F28D0CBE8CCC',
}

export const SAFE_WALLET: { [chainId: number]: Address } = {
  [zkSync.id]: '0xc0f2c32E7FF56318291c6bfA4C998A2F7213D2e0',
  [base.id]: '0xfb976Bae0b3Ef71843F1c6c63da7Df2e44B3836d',
  [arbitrum.id]: '0x290D9de8d51fDf4683Aa761865743a28909b2553',
}

export const TREASURY: { [chainId: number]: Address } = {
  [zkSync.id]: '0xfc5899d93df81ca11583bee03865b7b13ce093a7',
  [base.id]: '0xfc5899d93df81ca11583bee03865b7b13ce093a7',
  [arbitrum.id]: '0xc60eb261CD031F7ccf4b6cbd9ae677E11456A22a',
}

export const DEFAULT_BROKER_SHARE_RATIO: { [chainId: number]: number } = {
  [arbitrumSepolia.id]: 700_000,
  [base.id]: 700_000,
  [berachainTestnetbArtio.id]: 700_000,
}
