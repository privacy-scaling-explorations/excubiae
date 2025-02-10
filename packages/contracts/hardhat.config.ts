import { HardhatUserConfig } from "hardhat/config"
import { resolve } from "path"
import { config as dotenvConfig } from "dotenv"
import "@nomicfoundation/hardhat-toolbox"
import "@nomicfoundation/hardhat-foundry"
import "@nomicfoundation/hardhat-verify"
import "hardhat-gas-reporter"
import "./tasks/accounts"
import "./tasks/extensions/semaphore"

dotenvConfig({ path: resolve(__dirname, ".env") })

const backendPrivateKey = process.env.BACKEND_PRIVATE_KEY

const config: HardhatUserConfig = {
    solidity: {
        version: "0.8.28",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache-hh",
        artifacts: "./artifacts"
    },
    networks: {
        hardhat: {
            chainId: 1337,
            allowUnlimitedContractSize: true
        },
        sepolia: {
            chainId: 11155111,
            url: "https://rpc2.sepolia.org",
            accounts: !backendPrivateKey ? [] : [backendPrivateKey]
        }
    },
    gasReporter: {
        currency: "USD",
        enabled: process.env.REPORT_GAS === "true",
        coinmarketcap: process.env.COINMARKETCAP_API_KEY
    },
    typechain: {
        target: "ethers-v6"
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
        customChains: []
    },
    sourcify: {
        enabled: true
    }
}

export default config
