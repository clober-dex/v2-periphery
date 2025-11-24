import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { deployWithVerify, BOOK_MANAGER, deployCreate3WithVerify, SAFE_WALLET } from '../utils'
import { getChain, isDevelopmentNetwork } from '@nomicfoundation/hardhat-viem/internal/chains'
import { Address, encodeFunctionData } from 'viem'
import { monadPrivateMainnet } from '../utils/chains'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const chain = await getChain(network.provider)
  const deployer = (await getNamedAccounts())['deployer'] as Address

  if (await deployments.getOrNull('BookViewer_Implementation')) {
    return
  }

  let owner: Address = '0x'
  if (chain.testnet || isDevelopmentNetwork(chain.id)) {
    owner = deployer
  } else if (chain.id === monadPrivateMainnet.id) {
    owner = deployer
  } else {
    owner = SAFE_WALLET[chain.id] // Safe
    if (owner == undefined) {
      throw new Error('Unknown chain')
    }
  }

  const implementation = (await deployWithVerify(hre, 'BookViewer_Implementation', [BOOK_MANAGER[chain.id]], {
    contract: 'BookViewer',
  })) as Address

  let viewer = (await deployments.getOrNull('BookViewer'))?.address
  const bookViewerArtifact = await hre.artifacts.readArtifact('BookViewer')
  if (!viewer) {
    const initData = encodeFunctionData({
      abi: bookViewerArtifact.abi,
      functionName: '__BookViewer_init',
      args: [owner],
    })
    viewer = await deployCreate3WithVerify(deployer, 0xffffn + 6n, 'BookViewer_Proxy', [implementation, initData], {
      contract: 'ERC1967Proxy',
    })
  }

  await deployments.save('BookViewer', {
    address: viewer,
    abi: bookViewerArtifact.abi,
    implementation: implementation,
  })
}

deployFunction.tags = ['BookViewer']
export default deployFunction
