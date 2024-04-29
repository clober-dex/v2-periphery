import { arbitrumSepolia, base, berachainTestnet } from 'viem/chains'
import { Address } from 'viem'

export const BOOK_MANAGER: { [chainId: number]: Address } = {
  [arbitrumSepolia.id]: '0x3a90fbD5DbE4C82018A4Ac28406A50917dB91def',
  [base.id]: '0x59fAD5b95e755034572702991ABBA937Cc90254a',
  [berachainTestnet.id]: '0x982c57388101D012846aDC4997E9b073F3bC16BD',
}
