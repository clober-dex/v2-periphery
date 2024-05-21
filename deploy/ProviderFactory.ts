import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { deployWithVerify, BOOK_MANAGER, deployCreate3WithVerify, DEFAULT_BROKER_SHARE_RATIO } from '../utils'
import { getChain, isDevelopmentNetwork } from '@nomicfoundation/hardhat-viem/internal/chains'
import { Address, encodeFunctionData } from 'viem'
import { base } from 'viem/chains'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const deployer = (await getNamedAccounts())['deployer'] as Address
  const chain = await getChain(network.provider)

  if (await deployments.getOrNull('ProviderFactory')) {
    return
  }

  let owner: Address
  let treasury: Address
  const bookManager = BOOK_MANAGER[chain.id]
  const defaultBrokerShareRatio = DEFAULT_BROKER_SHARE_RATIO[chain.id]
  if (chain.testnet || isDevelopmentNetwork(chain.id)) {
    owner = treasury = deployer
  } else if (chain.id === base.id) {
    owner = '0xfb976Bae0b3Ef71843F1c6c63da7Df2e44B3836d' // Safe
    treasury = '0xfc5899d93df81ca11583bee03865b7b13ce093a7'
  } else {
    throw new Error('Unknown chain')
  }

  const implementation = (await deployWithVerify(hre, 'ProviderFactory_Implementation', [], {
    contract: 'ProviderFactory',
  })) as Address
  const providerFactoryArtifact = await hre.artifacts.readArtifact('ProviderFactory')
  const initData = encodeFunctionData({
    abi: providerFactoryArtifact.abi,
    functionName: '__ProviderFactory_init',
    args: [owner, bookManager, treasury, defaultBrokerShareRatio],
  })
  const providerFactory = await deployCreate3WithVerify(
    deployer,
    0xfffn,
    'ProviderFactory_Proxy',
    [implementation, initData],
    {
      contract: 'ERC1967Proxy',
    },
  )
  await deployments.save('ProviderFactory', {
    address: providerFactory,
    abi: providerFactoryArtifact.abi,
    implementation: implementation,
  })
}

deployFunction.tags = ['ProviderFactory']
export default deployFunction
