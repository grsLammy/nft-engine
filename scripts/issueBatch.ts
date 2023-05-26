import { providers, Wallet, utils } from "ethers";
import ps from "prompt-sync";
const prompt = ps();
import { config } from "dotenv";
import { abi } from "../artifacts/src/NFTEngine.sol/NFTEngine.json";
import { ethers } from "hardhat";
config();

const pKey: any = process.env.PRIVATE_KEY;
const nftEngine_address: any = process.env.NFT_ENGINE;
const zkEVM_RPC: any = process.env.RPC_URL;

async function issueBatch() {
    try {
        const provider = new providers.JsonRpcProvider(zkEVM_RPC);
        const nonce = await provider.getTransactionCount("0xB75D71adFc8E5F7c58eA89c22C3B70BEA84A718d");
        const signer = new Wallet(pKey, provider);
        const nftEngine_ABI = abi;
        const nftEngine_contract = new ethers.Contract(nftEngine_address, nftEngine_ABI, provider);
        const nftEngine_connect = nftEngine_contract.connect(signer);

        console.log("\n");
        const recipient = prompt("Enter the receipient address: ");
        if (!recipient) return console.log("Recipient address cannot be null");
        if (recipient.length !== 42) return console.log(`${recipient} is not a valid address`);

        const totalNumber = prompt("Enter the total number of NFTs to Mint: ");

        const id = prompt("Enter the starting hash id of NFTs to Mint from: ");
        if (!id) return console.log("Starting hash id of NFTs to Mint from cannot be null");

        let hashes: any = [];
        for (let i = 0; i < totalNumber; i++) {
            let newId = parseInt(id) + i;
            let hash = `hash_${newId}`;
            hashes.push(hash);
        }

        const estimatedGasLimit = await nftEngine_connect.estimateGas.issueBatch(recipient, hashes, {
            gasLimit: 14_999_999,
            nonce: nonce,
        });

        console.log(`estimatedGas: ${estimatedGasLimit}`);

        const txIssueBatch = await nftEngine_connect.issueBatch(recipient, hashes, {
            gasLimit: estimatedGasLimit,
            nonce: nonce,
        });
        await txIssueBatch.wait();
        console.log(txIssueBatch);

        const txHashIssueBatch = txIssueBatch.hash;

        console.log(hashes);

        console.log("\nTransaction Hash: ", txHashIssueBatch);
        console.log(`Transaction Details:  https://public.zkevm-test.net:8443/tx/${txHashIssueBatch}`);
        console.log(`\nNFTs minted successfully\n`);
    } catch (error) {
        console.log("Error in issueBatch: ", error);
        process.exit(1);
    }
}

issueBatch();
