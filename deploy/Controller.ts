import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { deployWithVerify } from '../utils'
import { BOOK_MANAGER } from '../utils/constants'
import { getChain } from '@nomicfoundation/hardhat-viem/internal/chains'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const chain = await getChain(hre.network.provider)
  await deployWithVerify(hre, 'Controller', [BOOK_MANAGER[chain.id]])
}

deployFunction.tags = ['Controller']
deployFunction.dependencies = ['BookManager']
export default deployFunction
