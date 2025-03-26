/* eslint-disable no-console */
import { task } from "hardhat/config"
import EASModule from "../../ignition/modules/extensions/EAS"

task("deploy:eas", "Deploys the EAS Extension Module")
    .addParam("eas", "Address of the EAS contract")
    .addParam("attester", "The trusted attester")
    .addParam("schema", "The schema to check against")
    .setAction(async (taskArgs, hre) => {
        const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(EASModule, {
            parameters: {
                eas: taskArgs.eas,
                attester: taskArgs.attester,
                schema: taskArgs.schema
            }
        })

        console.log("Deployment addresses:")
        console.log(`CheckerFactory: ${await checkerFactory.getAddress()}`)
        console.log(`Checker: ${await checker.getAddress()}`)
        console.log(`PolicyFactory: ${await policyFactory.getAddress()}`)
        console.log(`Policy: ${await policy.getAddress()}`)
    })
