/* eslint-disable no-console */
import { task, types } from "hardhat/config"
import SemaphoreModule from "../../ignition/modules/extensions/Semaphore"

task("deploy:semaphore", "Deploys the Semaphore Extension Module")
    .addParam("semaphoreAddress", "Address of the Semaphore contract")
    .addParam("groupId", "Group ID for the Semaphore checker", undefined, types.int)
    .setAction(async (taskArgs, hre) => {
        const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(SemaphoreModule, {
            parameters: {
                semaphoreAddress: taskArgs.semaphoreAddress,
                groupId: taskArgs.groupId
            }
        })

        console.log("Deployment addresses:")
        console.log(`CheckerFactory: ${await checkerFactory.getAddress()}`)
        console.log(`Checker: ${await checker.getAddress()}`)
        console.log(`PolicyFactory: ${await policyFactory.getAddress()}`)
        console.log(`Policy: ${await policy.getAddress()}`)
    })
