/* eslint-disable no-console */
import { task, types } from "hardhat/config"
import GitcointPassportModule from "../../ignition/modules/extensions/GitcoinPassport"

task("deploy:gitcoin", "Deploys the Gitcoin Passport Extension Module")
    .addParam("decoderAddress", "the gitcoin passport decoder instance")
    .addParam("minimumScore", "the threshold score to be considered human", undefined, types.int)
    .setAction(async (taskArgs, hre) => {
        const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(GitcointPassportModule, {
            parameters: {
                decoderAddress: taskArgs.decoderAddress,
                minimumScore: taskArgs.minimumScore
            }
        })

        console.log("Deployment addresses:")
        console.log(`CheckerFactory: ${await checkerFactory.getAddress()}`)
        console.log(`Checker: ${await checker.getAddress()}`)
        console.log(`PolicyFactory: ${await policyFactory.getAddress()}`)
        console.log(`Policy: ${await policy.getAddress()}`)
    })
