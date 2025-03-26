import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("AnonAadhaarModule", (m: any) => {
    const verifierAddress = m.getParameter("verifierAddress", "string")
    const nullifierSeed = m.getParameter("nullifierSeed", "string")

    const checkerFactory = m.contract("AnonAadhaarCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [verifierAddress, nullifierSeed])

    const policyFactory = m.contract("AnonAadhaarPolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
