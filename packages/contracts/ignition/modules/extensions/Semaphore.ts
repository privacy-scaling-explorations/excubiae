import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("SemaphoreModule", (m: any) => {
    const semaphoreAddress = m.getParameter("semaphoreAddress", "string")
    const groupId = m.getParameter("groupId", "number")

    const checkerFactory = m.contract("SemaphoreCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [semaphoreAddress, groupId])

    const policyFactory = m.contract("SemaphorePolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
