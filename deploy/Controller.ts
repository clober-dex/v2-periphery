import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { deployWithVerify, getDeployedAddress } from '../utils'

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  await deployWithVerify(hre, 'Controller', [await getDeployedAddress('BookManager')])
}

deployFunction.tags = ['Controller']
deployFunction.dependencies = ['BookManager']
export default deployFunction
