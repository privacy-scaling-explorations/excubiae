import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("SemaphoreModule", (m: any) => {
    // Module parameters.
    const semaphoreAddress = m.getParameter("semaphoreAddress", "string")
    const groupId = m.getParameter("groupId", "number")

    // Deploy SemaphoreCheckerFactory.
    const semaphoreCheckerFactory = m.contract("SemaphoreCheckerFactory", [])

    // Deploy SemaphoreChecker using the factory's deploy function.
    const checker = m.call(semaphoreCheckerFactory, "deploy", [semaphoreAddress, groupId])

    // Deploy SemaphorePolicyFactory.
    const semaphorePolicyFactory = m.contract("SemaphorePolicyFactory", [])

    // Deploy SemaphorePolicy using the factory's deploy function.
    const policy = m.call(semaphorePolicyFactory, "deploy", [checker.contract])

    return {
        semaphoreCheckerFactory,
        checker,
        semaphorePolicyFactory,
        policy
    }
})
