/* eslint-disable no-console */
import { task } from "hardhat/config"
import HatsModule from "../../ignition/modules/extensions/Hats"

task("deploy:hats", "Deploys the Hats Extension Module")
    .addParam("hats", "The Hats Protocol contract address")
    .addParam("criterionHats", "Criterion hats that users must wear to be eligible")
    .setAction(async (taskArgs, hre) => {
        const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(HatsModule, {
            parameters: {
                hats: taskArgs.hats,
                criterionHats: taskArgs.criterionHats.split(/\s*,\s*/)
            }
        })

        console.log("Deployment addresses:")
        console.log(`CheckerFactory: ${await checkerFactory.getAddress()}`)
        console.log(`Checker: ${await checker.getAddress()}`)
        console.log(`PolicyFactory: ${await policyFactory.getAddress()}`)
        console.log(`Policy: ${await policy.getAddress()}`)
    })
