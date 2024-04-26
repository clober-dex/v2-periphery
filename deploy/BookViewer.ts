import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { deployWithVerify, getDeployedAddress } from '../utils'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  await deployWithVerify(hre, 'BookViewer', [await getDeployedAddress('BookManager')], null, true)
}

deployFunction.tags = ['BookViewer']
deployFunction.dependencies = ['BookManager']
export default deployFunction
