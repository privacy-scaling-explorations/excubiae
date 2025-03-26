import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("FreeForAllModule", (m: any) => {
    const checkerFactory = m.contract("FreeForAllCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [])

    const policyFactory = m.contract("FreeForAllPolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
