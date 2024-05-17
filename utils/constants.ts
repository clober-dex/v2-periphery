import { arbitrumSepolia, base, berachainTestnet, zkSync, zkSyncSepoliaTestnet } from 'viem/chains'
import { Address } from 'viem'

export const BOOK_MANAGER: { [chainId: number]: Address } = {
  [arbitrumSepolia.id]: '0xC528b9ED5d56d1D0d3C18A2342954CE1069138a4',
  [base.id]: '0x382CCccbD3b142D7DA063bF68cd0c89634767F76',
  [berachainTestnet.id]: '0x982c57388101D012846aDC4997E9b073F3bC16BD',
  [zkSync.id]: '0x5961268BFd6b057c3ffA4709eDb920bD97011B13',
  [zkSyncSepoliaTestnet.id]: '0x419DD5a4e74f96e57C1F8B8B46ae6855395A9de7',
}
