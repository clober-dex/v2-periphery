import { Wallet } from 'zksync-ethers'
import * as ethers from 'ethers'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { Deployer } from '@matterlabs/hardhat-zksync-deploy'

// load env file
import dotenv from 'dotenv'
import { BOOK_MANAGER } from '../utils/constants'
import { getChain } from '@nomicfoundation/hardhat-viem/internal/chains'
dotenv.config()

// load wallet private key from env file
const PRIVATE_KEY = process.env.DEV_PRIVATE_KEY || ''

if (!PRIVATE_KEY) throw '⛔️ Private key not detected! Add it to the .env file!'

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  const chain = await getChain(hre.network.provider)
  console.log(`Running deploy script for the Controller/Viewer contract`)

  // Initialize the wallet.
  const wallet = new Wallet(PRIVATE_KEY)

  // Create deployer object and load the artifact of the contract you want to deploy.
  const deployer = new Deployer(hre, wallet)
  const controllerArtifact = await deployer.loadArtifact('Controller')

  // Estimate contract deployment fee
  const bookManager = BOOK_MANAGER[chain.id]
  let deploymentFee = await deployer.estimateDeployFee(controllerArtifact, [bookManager])

  let parsedFee = ethers.formatEther(deploymentFee)
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`)

  const controllerContract = await deployer.deploy(controllerArtifact, [bookManager])

  //obtain the Constructor Arguments
  console.log('constructor args:' + controllerContract.interface.encodeDeploy([bookManager]))

  // Show the contract info.
  const controllerAddress = await controllerContract.getAddress()
  console.log(`${controllerArtifact.contractName} was deployed to ${controllerAddress}`)

  await hre.run("verify:verify", {
    address: controllerAddress,
    constructorArguments: [bookManager],
    contract: 'src/Controller.sol:Controller'
  })

  const viewerArtifact = await deployer.loadArtifact('BookViewer')
  deploymentFee = await deployer.estimateDeployFee(viewerArtifact, [bookManager])
  parsedFee = ethers.formatEther(deploymentFee)
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`)

  const viewerContract = await deployer.deploy(viewerArtifact, [bookManager])

  //obtain the Constructor Arguments
  console.log('constructor args:' + viewerContract.interface.encodeDeploy([bookManager]))

  // Show the contract info.
  const viewerAddress = await viewerContract.getAddress()
  console.log(`${viewerArtifact.contractName} was deployed to ${viewerAddress}`)

  await hre.run("verify:verify", {
    address: viewerAddress,
    constructorArguments: [bookManager],
    contract: 'src/BookViewer.sol:BookViewer'
  })
}
