import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("ZupassModule", (m: any) => {
    const eventId = m.getParameter("eventId", "string")
    const signer1 = m.getParameter("signer1", "string")
    const signer2 = m.getParameter("signer2", "string")
    const verifier = m.getParameter("verifier", "string")

    const checkerFactory = m.contract("ZupassCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [eventId, signer1, signer2, verifier])

    const policyFactory = m.contract("ZupassPolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
