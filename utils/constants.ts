import { arbitrum, arbitrumSepolia, base, berachainTestnetbArtio, zkSync, zkSyncSepoliaTestnet } from 'viem/chains'
import { Address } from 'viem'

export const BOOK_MANAGER: { [chainId: number]: Address } = {
  [arbitrumSepolia.id]: '0xC528b9ED5d56d1D0d3C18A2342954CE1069138a4',
  [base.id]: '0x382CCccbD3b142D7DA063bF68cd0c89634767F76',
  [berachainTestnetbArtio.id]: '0x874b1B795993653fbFC3f1c1fc0469214cC9F4A5',
  [zkSyncSepoliaTestnet.id]: '0x76F479c6ae5Cdd3180C9cAa09bEefeBC78fdB931',
  [zkSync.id]: '0xDC5C6B6246Aa719D39b511F808bE27583240bAa9',
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
