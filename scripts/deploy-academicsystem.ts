import { ethers } from "hardhat";
import { AcademicSystem } from "../typechain-types";

async function main() {
  console.log("🚀 Starting AcademicSystem deployment to Monad Testnet...\n");

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
  const AcademicSystemFactory = await ethers.getContractFactory(
    "AcademicSystem"
  );

  // Estimate gas
  const deployTx = await AcademicSystemFactory.getDeployTransaction();
  const estimatedGas = await ethers.provider.estimateGas(deployTx);
  console.log("├── Estimated gas:", estimatedGas.toString());

  // Deploy with manual gas limit (adding 20% buffer)
  const gasLimit = (estimatedGas * BigInt(120)) / BigInt(100);
  const academicSystem: AcademicSystem = await AcademicSystemFactory.deploy({
    gasLimit: gasLimit,
  });

  console.log(
    "├── Transaction hash:",
    academicSystem.deploymentTransaction()?.hash
  );
  console.log("├── Waiting for deployment confirmation...");

  // Wait for deployment
  await academicSystem.waitForDeployment();
  const contractAddress = await academicSystem.getAddress();

  console.log("✅ AcademicSystem deployed successfully!");
  console.log("├── Contract address:", contractAddress);
  console.log(
    "├── Block explorer:",
    `https://testnet.monadexplorer.com/address/${contractAddress}`
  );

  return {
    academicSystem: academicSystem,
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
