import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { BOOK_MANAGER, deployWithVerify, SAFE_WALLET } from '../utils'
import { getChain, isDevelopmentNetwork } from '@nomicfoundation/hardhat-viem/internal/chains'
import { Address } from 'viem'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const chain = await getChain(network.provider)
  const deployer = (await getNamedAccounts())['deployer'] as Address

  if (await deployments.getOrNull('Arbitrage')) {
    return
  }

  let owner: Address
  if (chain.testnet || isDevelopmentNetwork(chain.id)) {
    owner = deployer
  } else {
    owner = SAFE_WALLET[chain.id] // Safe
    if (owner == undefined) {
      throw new Error('Unknown chain')
    }
  }

  await deployWithVerify(hre, 'Arbitrage', [BOOK_MANAGER[chain.id], owner])
}

deployFunction.tags = ['Arbitrage']
export default deployFunction
