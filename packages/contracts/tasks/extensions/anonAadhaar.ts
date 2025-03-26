/* eslint-disable no-console */
import { task } from "hardhat/config"
import AnonAadhaarModule from "../../ignition/modules/extensions/AnonAadhaar"

task("deploy:anon-aadhaar", "Deploys the AnonAadhaar Extension Module")
    .addParam("verifierAddress", "Address of the AnonAadhaar verifier contract")
    .addParam("nullifierSeed", "Nullifier seed")
    .setAction(async (taskArgs, hre) => {
        const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(AnonAadhaarModule, {
            parameters: {
                verifierAddress: taskArgs.verifierAddress,
                nullifierSeed: taskArgs.nullifierSeed
            }
        })

        console.log("Deployment addresses:")
        console.log(`CheckerFactory: ${await checkerFactory.getAddress()}`)
        console.log(`Checker: ${await checker.getAddress()}`)
        console.log(`PolicyFactory: ${await policyFactory.getAddress()}`)
        console.log(`Policy: ${await policy.getAddress()}`)
    })
