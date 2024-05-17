import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { BOOK_MANAGER, deployCreate3WithVerify } from '../utils'
import { getChain } from '@nomicfoundation/hardhat-viem/internal/chains'
import { Address } from 'viem'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  if (await deployments.getOrNull('Controller')) {
    return
  }

  const deployer = (await getNamedAccounts())['deployer'] as Address
  const chain = await getChain(hre.network.provider)
  await deployCreate3WithVerify(deployer, 0xffffn + 1n, 'Controller', [BOOK_MANAGER[chain.id]])
}

deployFunction.tags = ['Controller']
export default deployFunction
