/* eslint-disable no-console */
import { task } from "hardhat/config"
import FreeForAllModule from "../../ignition/modules/extensions/FreeForAll"

task("deploy:free-for-all", "Deploys the FreeForAll Extension Module").setAction(async (taskArgs, hre) => {
    const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(FreeForAllModule, {
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
