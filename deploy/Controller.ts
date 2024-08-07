import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { BOOK_MANAGER, deployCreate3WithVerify, deployWithVerify, SAFE_WALLET } from '../utils'
import { getChain, isDevelopmentNetwork } from '@nomicfoundation/hardhat-viem/internal/chains'
import { Address } from 'viem'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  if (await deployments.getOrNull('Controller')) {
    return
  }

  const chain = await getChain(network.provider)
  const deployer = (await getNamedAccounts())['deployer'] as Address

  await deployCreate3WithVerify(deployer, 0xffffn + 2n, 'Controller', [BOOK_MANAGER[chain.id]])
}

deployFunction.tags = ['Controller']
export default deployFunction
