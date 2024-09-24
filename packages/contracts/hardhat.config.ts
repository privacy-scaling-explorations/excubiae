import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "@nomicfoundation/hardhat-foundry"

const config: HardhatUserConfig = {
    solidity: "0.8.27",
    paths: {
        sources: "./contracts/src",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
    }
}

export default config
