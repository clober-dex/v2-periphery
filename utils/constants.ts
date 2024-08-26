import {arbitrumSepolia, base, arbitrum, berachainTestnetbArtio} from 'viem/chains'
import { Address } from 'viem'

export const BOOK_MANAGER: { [chainId: number]: Address } = {
  [arbitrumSepolia.id]: '0xC528b9ED5d56d1D0d3C18A2342954CE1069138a4',
  [base.id]: '0x382CCccbD3b142D7DA063bF68cd0c89634767F76',
  [berachainTestnetbArtio.id]: '0x874b1B795993653fbFC3f1c1fc0469214cC9F4A5',
}

export const SAFE_WALLET: { [chainId: number]: Address } = {
  [base.id]: '0xfb976Bae0b3Ef71843F1c6c63da7Df2e44B3836d',
  [arbitrum.id]: '0x290D9de8d51fDf4683Aa761865743a28909b2553',
}
