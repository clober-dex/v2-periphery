import { arbitrumSepolia, base, berachainTestnet, arbitrum } from 'viem/chains'
import { Address } from 'viem'

export const BOOK_MANAGER: { [chainId: number]: Address } = {
  [arbitrumSepolia.id]: '0xC528b9ED5d56d1D0d3C18A2342954CE1069138a4',
  [base.id]: '0x382CCccbD3b142D7DA063bF68cd0c89634767F76',
  [berachainTestnet.id]: '0x982c57388101D012846aDC4997E9b073F3bC16BD',
}

export const DEFAULT_BROKER_SHARE_RATIO: { [chainId: number]: number } = {
  [arbitrumSepolia.id]: 700_000,
  [base.id]: 700_000,
  [berachainTestnet.id]: 700_000,
}

export const SAFE_WALLET: { [chainId: number]: Address } = {
  [base.id]: '0xfb976Bae0b3Ef71843F1c6c63da7Df2e44B3836d',
  [arbitrum.id]: '0x290D9de8d51fDf4683Aa761865743a28909b2553',
}
