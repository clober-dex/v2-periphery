import { arbitrumSepolia } from 'viem/chains'
import { Address } from 'viem'

export const BOOK_MANAGER: { [chainId: number]: Address } = {
  [arbitrumSepolia.id]: '0x3a90fbD5DbE4C82018A4Ac28406A50917dB91def',
}
