import { expect } from "chai"
import { Signer, ZeroAddress, AbiCoder } from "ethers"
import { ethers } from "hardhat"

import {
    GitcoinPassportChecker__factory as GitcoinPassportCheckerFactory,
    GitcoinPassportPolicy__factory as GitcoinPassportPolicyFactory,
    GitcoinPassportChecker,
    GitcoinPassportPolicy,
    MockGitcoinPassportDecoder
} from "../../typechain-types"

describe("GitcoinPassport", () => {
    let policy: GitcoinPassportPolicy
    let checker: GitcoinPassportChecker
    let mockDecoder: MockGitcoinPassportDecoder
    let deployer: Signer
    let subject: Signer
    let target: Signer
    let notSubject: Signer

    let decoderAddress: string

    // @note score is 4 digit (2 decimals)
    // 50.00
    const passingScore = 5000

    before(async () => {
        ;[deployer, subject, target, notSubject] = await ethers.getSigners()

        const mockGitcoinPassportDecoderFactory = await ethers.getContractFactory("MockGitcoinPassportDecoder")
        mockDecoder = await mockGitcoinPassportDecoderFactory.connect(deployer).deploy()
        decoderAddress = await mockDecoder.getAddress()

        const CheckerFactory = await ethers.getContractFactory("GitcoinPassportCheckerFactory")
        const checkerFactory = await CheckerFactory.connect(deployer).deploy()

        const PolicyFactory = await ethers.getContractFactory("GitcoinPassportPolicyFactory")
        const policyFactory = await PolicyFactory.connect(deployer).deploy()

        const checkerTx = await checkerFactory.deploy(decoderAddress, passingScore)
        const checkerReceipt = await checkerTx.wait()

        const checkerDeployEvent = CheckerFactory.interface.parseLog(
            checkerReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        checker = GitcoinPassportCheckerFactory.connect(checkerDeployEvent.args.clone, deployer)

        const policyTx = await policyFactory.deploy(checkerDeployEvent.args.clone)
        const policyReceipt = await policyTx.wait()
        const policyEvent = PolicyFactory.interface.parseLog(
            policyReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        policy = GitcoinPassportPolicyFactory.connect(policyEvent.args.clone, deployer)
    })

    describe("Deployment", () => {
        it("should be deployed correctly", () => {
            expect(policy).to.not.eq(undefined)
        })
    })

    describe("Policy", () => {
        it("should set guarded target correctly", async () => {
            await policy.setTarget(target).then((tx) => tx.wait())

            expect(await policy.guarded()).to.eq(target)
        })

        it("should return trait properly", async () => {
            expect(await policy.trait()).to.eq("GitcoinPassport")
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

        it("should throw when the score is not high enough", async () => {
            await expect(policy.connect(target).enforce(subject, "0x")).to.be.revertedWithCustomError(
                checker,
                "ScoreTooLow"
            )
        })

        it("should allow to signup when the score is high enough", async () => {
            await mockDecoder.changeScore(passingScore * 100).then((tx) => tx.wait())
            await policy
                .connect(target)
                .enforce(subject, "0x")
                .then((tx) => tx.wait())

            expect(await policy.enforcedUsers(subject)).to.eq(true)
        })

        it("should prevent signing up twice", async () => {
            await expect(policy.connect(target).enforce(subject, "0x")).to.be.revertedWithCustomError(
                policy,
                "AlreadyEnforced"
            )
        })

        it("should enforce user properly", async () => {
            const tx = await policy
                .connect(target)
                .enforce(deployer, AbiCoder.defaultAbiCoder().encode(["uint256"], [1]))

            const receipt = await tx.wait()

            expect(receipt?.status).to.eq(1)
        })
    })
})
