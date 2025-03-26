import { expect } from "chai"
import { Signer, ZeroAddress, AbiCoder } from "ethers"
import { ethers } from "hardhat"

import {
    TokenChecker__factory as TokenCheckerFactory,
    TokenPolicy__factory as TokenPolicyFactory,
    TokenChecker,
    TokenPolicy,
    MockToken
} from "../../typechain-types"

describe("Token", () => {
    let policy: TokenPolicy
    let checker: TokenChecker
    let signUpToken: MockToken
    let deployer: Signer
    let subject: Signer
    let target: Signer
    let notSubject: Signer

    before(async () => {
        ;[deployer, subject, target, notSubject] = await ethers.getSigners()

        const mockSignupTokenFactory = await ethers.getContractFactory("MockToken")
        signUpToken = await mockSignupTokenFactory.connect(deployer).deploy()

        const CheckerFactory = await ethers.getContractFactory("TokenCheckerFactory")
        const checkerFactory = await CheckerFactory.connect(deployer).deploy()

        const PolicyFactory = await ethers.getContractFactory("TokenPolicyFactory")
        const policyFactory = await PolicyFactory.connect(deployer).deploy()

        const checkerTx = await checkerFactory.deploy(signUpToken)
        const checkerReceipt = await checkerTx.wait()

        const checkerDeployEvent = CheckerFactory.interface.parseLog(
            checkerReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        checker = TokenCheckerFactory.connect(checkerDeployEvent.args.clone, deployer)

        const policyTx = await policyFactory.deploy(checkerDeployEvent.args.clone)
        const policyReceipt = await policyTx.wait()
        const policyEvent = PolicyFactory.interface.parseLog(
            policyReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        policy = TokenPolicyFactory.connect(policyEvent.args.clone, deployer)
    })

    describe("Deployment", () => {
        it("should be deployed correctly", async () => {
            expect(policy).to.not.eq(undefined)
            expect(checker).to.not.eq(undefined)
            expect(signUpToken).to.not.eq(undefined)
            expect(await checker.token()).to.eq(await signUpToken.getAddress())
        })
    })

    describe("Policy", () => {
        it("should set guarded target correctly", async () => {
            await policy.setTarget(target).then((tx) => tx.wait())

            expect(await policy.guarded()).to.eq(target)
        })

        it("should return trait properly", async () => {
            expect(await policy.trait()).to.eq("Token")
        })

        it("should fail to set guarded target when the caller is not the owner", async () => {
            await expect(policy.connect(notSubject).setTarget(target)).to.be.revertedWithCustomError(
                policy,
                "OwnableUnauthorizedAccount"
            )
        })

        it("should fail to set guarded target when the target is not valid", async () => {
            await expect(policy.setTarget(ZeroAddress)).to.be.revertedWithCustomError(policy, "ZeroAddress")
        })

        it("should not allow to call from a non-target contract", async () => {
            await expect(
                policy.enforce(subject, AbiCoder.defaultAbiCoder().encode(["uint256"], [1]))
            ).to.be.revertedWithCustomError(policy, "TargetOnly")
        })

        it("should fail if subject is not an owner of token", async () => {
            await signUpToken.giveToken(subject, 1)

            await expect(
                policy.connect(target).enforce(notSubject, AbiCoder.defaultAbiCoder().encode(["uint256"], [1]))
            ).to.be.revertedWithCustomError(checker, "NotTokenOwner")
        })

        it("should enforce a user if the function is called by a target", async () => {
            await signUpToken.giveToken(subject, 0)

            const tx = await policy
                .connect(target)
                .enforce(subject, AbiCoder.defaultAbiCoder().encode(["uint256"], [0]))

            const receipt = await tx.wait()

            expect(receipt?.status).to.eq(1)
        })

        it("should prevent enforcing twice", async () => {
            await expect(
                policy.connect(target).enforce(subject, AbiCoder.defaultAbiCoder().encode(["uint256"], [0]))
            ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
        })
    })
})
