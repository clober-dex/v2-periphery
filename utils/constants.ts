import { arbitrumSepolia, base, berachainTestnet } from 'viem/chains'
import { Address } from 'viem'

export const BOOK_MANAGER: { [chainId: number]: Address } = {
  [arbitrumSepolia.id]: '0x3a90fbD5DbE4C82018A4Ac28406A50917dB91def',
  [base.id]: '0x59fAD5b95e755034572702991ABBA937Cc90254a',
  [berachainTestnet.id]: '0xA7e0051561D5b955F1014939FB54F71C7F4AEdF1',
}
