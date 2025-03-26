import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("GitcoinPassportModule", (m: any) => {
    const decoderAddress = m.getParameter("decoderAddress", "string")
    const minimumScore = m.getParameter("minimumScore", "number")

    const checkerFactory = m.contract("GitcoinPassportCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [decoderAddress, minimumScore])

    const policyFactory = m.contract("GitcointPassportPolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
