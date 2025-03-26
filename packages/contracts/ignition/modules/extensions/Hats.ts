import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("HatsModule", (m: any) => {
    const hats = m.getParameter("hats")
    const criterionHats = m.getParameter("criterionHats", [])

    const checkerFactory = m.contract("HatsCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [hats, criterionHats])

    const policyFactory = m.contract("HatsPolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
