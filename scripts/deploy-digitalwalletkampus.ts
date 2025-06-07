import { ethers } from "hardhat";
import { DigitalWalletKampus } from "../typechain-types";

async function main() {
  console.log(
    "🚀 Starting DigitalWalletKampus deployment to Monad Testnet...\n"
  );

  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log("📋 Deployment Details:");
  console.log("├── Deployer address:", deployer.address);

  // Check balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("├── Deployer balance:", ethers.formatEther(balance), "MON");

  if (balance < ethers.parseEther("0.01")) {
    console.log(
      "⚠️  Warning: Low balance. Make sure you have enough MON for deployment."
    );
  }

  // Get network info
  const network = await ethers.provider.getNetwork();
  console.log("├── Network:", network.name);
  console.log("├── Chain ID:", network.chainId.toString());
  console.log("└── RPC URL:", "https://testnet-rpc.monad.xyz/\n");

  // Deploy TaskManager
  console.log("📦 Deploying TaskManager contract...");
  const DigitalWalletKampusFactory = await ethers.getContractFactory(
    "DigitalWalletKampus"
  );

  // Estimate gas
  const deployTx = await DigitalWalletKampusFactory.getDeployTransaction();
  const estimatedGas = await ethers.provider.estimateGas(deployTx);
  console.log("├── Estimated gas:", estimatedGas.toString());

  // Deploy with manual gas limit (adding 20% buffer)
  const gasLimit = (estimatedGas * BigInt(120)) / BigInt(100);
  const digitalWalletKampus: DigitalWalletKampus =
    await DigitalWalletKampusFactory.deploy({
      gasLimit: gasLimit,
    });

  console.log(
    "├── Transaction hash:",
    digitalWalletKampus.deploymentTransaction()?.hash
  );
  console.log("├── Waiting for deployment confirmation...");

  // Wait for deployment
  await digitalWalletKampus.waitForDeployment();
  const contractAddress = await digitalWalletKampus.getAddress();

  console.log("✅ DigitalWalletKampus deployed successfully!");
  console.log("├── Contract address:", contractAddress);
  console.log(
    "├── Block explorer:",
    `https://testnet.monadexplorer.com/address/${contractAddress}`
  );

  return {
    academicSystem: digitalWalletKampus,
    contractAddress,
  };
}

// Handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  });
