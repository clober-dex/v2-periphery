import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { deployWithVerify, BOOK_MANAGER } from '../utils'
import { getChain } from '@nomicfoundation/hardhat-viem/internal/chains'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const chain = await getChain(hre.network.provider)
  await deployWithVerify(hre, 'BookViewer', [BOOK_MANAGER[chain.id]], null, true)
}

deployFunction.tags = ['BookViewer']
deployFunction.dependencies = ['BookManager']
export default deployFunction
