import { Wallet } from 'zksync-ethers'
import * as ethers from 'ethers'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { Deployer } from '@matterlabs/hardhat-zksync-deploy'

// load env file
import dotenv from 'dotenv'
import { BOOK_MANAGER, SAFE_WALLET } from '../utils'
import { getChain, isDevelopmentNetwork } from '@nomicfoundation/hardhat-viem/internal/chains'
import chains, { zkSync, zkSyncSepoliaTestnet } from 'viem/chains'
import { Address } from 'viem'
import { getNamedAccounts } from 'hardhat'
dotenv.config()

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script for the Controller/Viewer contract`)
  const chain = await getChain(hre.network.provider)

  if (chain.id !== zkSyncSepoliaTestnet.id && chain.id !== zkSync.id) {
    throw new Error('Unsupported chain')
  }

  // Initialize the wallet.
  const accounts = hre.config.networks[chain.id].accounts
  if (!Array.isArray(accounts)) throw new Error('Invalid accounts')
  const privateKey = accounts[0]
  if (!privateKey) throw new Error('Private key not found')
  if (typeof privateKey !== 'string') throw new Error('Invalid private key')
  const wallet = new Wallet(privateKey)

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

  await hre.run('verify:verify', {
    address: controllerAddress,
    constructorArguments: [bookManager],
    contract: 'src/Controller.sol:Controller',
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

  await hre.run('verify:verify', {
    address: viewerAddress,
    constructorArguments: [bookManager],
    contract: 'src/BookViewer.sol:BookViewer',
  })

  let owner: Address
  if (chain.testnet || isDevelopmentNetwork(chain.id)) {
    owner = deployer.zkWallet.address as Address
  } else {
    owner = SAFE_WALLET[chain.id] // Safe
    if (owner == undefined) {
      throw new Error('Unknown chain')
    }
  }
  const arbitrageArtifact = await deployer.loadArtifact('Arbitrage')
  deploymentFee = await deployer.estimateDeployFee(arbitrageArtifact, [bookManager, owner])
  parsedFee = ethers.formatEther(deploymentFee)
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`)

  const arbitrageContract = await deployer.deploy(arbitrageArtifact, [bookManager, owner])

  //obtain the Constructor Arguments
  console.log('constructor args:' + arbitrageContract.interface.encodeDeploy([bookManager, owner]))

  // Show the contract info.
  const arbitrageAddress = await arbitrageContract.getAddress()
  console.log(`${arbitrageArtifact.contractName} was deployed to ${arbitrageAddress}`)

  await hre.run('verify:verify', {
    address: arbitrageAddress,
    constructorArguments: [bookManager, owner],
    contract: 'src/Arbitrage.sol:Arbitrage',
  })
}
