/* eslint-disable no-console */
import { task } from "hardhat/config"
import MerkleModule from "../../ignition/modules/extensions/Merkle"

task("deploy:merkle", "Deploys the Merkle Extension Module")
    .addParam("root", "The Merkle tree root")
    .setAction(async (taskArgs, hre) => {
        const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(MerkleModule, {
            parameters: {
                root: taskArgs.root
            }
        })

        console.log("Deployment addresses:")
        console.log(`CheckerFactory: ${await checkerFactory.getAddress()}`)
        console.log(`Checker: ${await checker.getAddress()}`)
        console.log(`PolicyFactory: ${await policyFactory.getAddress()}`)
        console.log(`Policy: ${await policy.getAddress()}`)
    })
