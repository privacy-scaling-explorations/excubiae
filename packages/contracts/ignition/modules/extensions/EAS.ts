import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("EASModule", (m: any) => {
    const eas = m.getParameter("eas", "string")
    const attester = m.getParameter("attester", "string")
    const schema = m.getParameter("schema", "string")

    const checkerFactory = m.contract("EASCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [eas, attester, schema])

    const policyFactory = m.contract("EASPolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
