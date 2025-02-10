import { task, types } from "hardhat/config"
import SemaphoreModule from "../../ignition/modules/extensions/Semaphore"

task("deploy:semaphore", "Deploys the Semaphore Extension Module")
    .addParam("semaphoreAddress", "Address of the Semaphore contract")
    .addParam("groupId", "Group ID for the Semaphore checker", undefined, types.int)
    .setAction(async (taskArgs, hre) => {
        const { semaphoreCheckerFactory, checker, semaphorePolicyFactory, policy } = await hre.ignition.deploy(
            SemaphoreModule,
            {
                parameters: {
                    semaphoreAddress: taskArgs.semaphoreAddress,
                    groupId: taskArgs.groupId
                }
            }
        )

        console.log("Deployment addresses:")
        console.log(`SemaphoreCheckerFactory: ${await semaphoreCheckerFactory.getAddress()}`)
        console.log(`SemaphoreChecker: ${await checker.getAddress()}`)
        console.log(`SemaphorePolicyFactory: ${await semaphorePolicyFactory.getAddress()}`)
        console.log(`SemaphorePolicy: ${await policy.getAddress()}`)
    })
