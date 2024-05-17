import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { deployWithVerify, BOOK_MANAGER, deployCreate3WithVerify } from '../utils'
import { getChain } from '@nomicfoundation/hardhat-viem/internal/chains'
import { Address, encodeFunctionData } from 'viem'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  if (await deployments.getOrNull('BookViewer')) {
    return
  }

  const deployer = (await getNamedAccounts())['deployer'] as Address
  const chain = await getChain(hre.network.provider)
  const implementation = (await deployWithVerify(hre, 'BookViewer_Implementation', [BOOK_MANAGER[chain.id]], {
    contract: 'BookViewer',
  })) as Address
  const bookViewerArtifact = await hre.artifacts.readArtifact('BookViewer')
  const initData = encodeFunctionData({
    abi: bookViewerArtifact.abi,
    functionName: '__BookViewer_init',
    args: [deployer],
  })
  const viewer = await deployCreate3WithVerify(deployer, 0xffffn, 'BookViewer_Proxy', [implementation, initData], {
    contract: 'ERC1967Proxy',
  })
  await deployments.save('BookViewer', {
    address: viewer,
    abi: bookViewerArtifact.abi,
    implementation: implementation,
  })
}

deployFunction.tags = ['BookViewer']
export default deployFunction
