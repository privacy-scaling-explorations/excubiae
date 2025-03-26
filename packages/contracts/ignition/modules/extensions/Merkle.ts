import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("MerkleModule", (m: any) => {
    const root = m.getParameter("root", "string")

    const checkerFactory = m.contract("MerkleCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [root])

    const policyFactory = m.contract("MerklePolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
