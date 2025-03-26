import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("TokenModule", (m: any) => {
    const tokenAddress = m.getParameter("token", "string")

    const checkerFactory = m.contract("SignUpTokenCheckerFactory", [])

    const checker = m.call(checkerFactory, "deploy", [tokenAddress])

    const policyFactory = m.contract("SignUpTokenPolicyFactory", [])

    const policy = m.call(policyFactory, "deploy", [checker.contract])

    return {
        checkerFactory,
        checker,
        policyFactory,
        policy
    }
})
