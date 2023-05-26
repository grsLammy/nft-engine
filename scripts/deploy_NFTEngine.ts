import { ethers } from "hardhat";
import { NFTEngine__factory } from "../src/types";

async function deploy() {
    // get the contract to deploy
    const NFTEngine = (await ethers.getContractFactory("NFTEngine")) as NFTEngine__factory;
    const nftEngine = await NFTEngine.deploy("NFT ENGINE zkEVM", "NEZ");
    console.log("\nDeploying NFTEngine smart contract on zkEVM chain....");
    function delay(ms: number) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    await delay(20000);
    console.log("\nNFT Engine contract deployed at: ", nftEngine.address);
    console.log(`https://public.zkevm-test.net:8443/address/${nftEngine.address}/`);
}

deploy();
