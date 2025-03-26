/* eslint-disable no-console */
import { task } from "hardhat/config"
import TokenModule from "../../ignition/modules/extensions/Token"

task("deploy:token", "Deploys the Token Extension Module")
    .addParam("token", "The token address")
    .setAction(async (taskArgs, hre) => {
        const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(TokenModule, {
            parameters: {
                token: taskArgs.token
            }
        })

        console.log("Deployment addresses:")
        console.log(`CheckerFactory: ${await checkerFactory.getAddress()}`)
        console.log(`Checker: ${await checker.getAddress()}`)
        console.log(`PolicyFactory: ${await policyFactory.getAddress()}`)
        console.log(`Policy: ${await policy.getAddress()}`)
    })
