import { expect } from "chai"
import { Signer, ZeroAddress, AbiCoder } from "ethers"
import { ethers } from "hardhat"

import {
    HatsChecker__factory as HatsCheckerFactory,
    HatsPolicy__factory as HatsPolicyFactory,
    HatsChecker,
    HatsPolicy,
    MockHatsProtocol
} from "../../typechain-types"

describe("Hats", () => {
    let policy: HatsPolicy
    let checker: HatsChecker
    let mockHats: MockHatsProtocol
    let deployer: Signer
    let subject: Signer
    let target: Signer
    let notSubject: Signer

    let mockHatsAddress: string

    const hatId = 1
    const secondHatId = 2
    const thirdHatId = 50

    before(async () => {
        ;[deployer, subject, target, notSubject] = await ethers.getSigners()

        const mockHatsFactory = await ethers.getContractFactory("MockHatsProtocol")
        mockHats = await mockHatsFactory.connect(deployer).deploy()
        mockHatsAddress = await mockHats.getAddress()

        const CheckerFactory = await ethers.getContractFactory("HatsCheckerFactory")
        const checkerFactory = await CheckerFactory.connect(deployer).deploy()

        const PolicyFactory = await ethers.getContractFactory("HatsPolicyFactory")
        const policyFactory = await PolicyFactory.connect(deployer).deploy()

        const checkerTx = await checkerFactory.deploy(mockHatsAddress, [hatId, thirdHatId])
        const checkerReceipt = await checkerTx.wait()

        const checkerDeployEvent = CheckerFactory.interface.parseLog(
            checkerReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        checker = HatsCheckerFactory.connect(checkerDeployEvent.args.clone, deployer)

        const policyTx = await policyFactory.deploy(checkerDeployEvent.args.clone)
        const policyReceipt = await policyTx.wait()
        const policyEvent = PolicyFactory.interface.parseLog(
            policyReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        policy = HatsPolicyFactory.connect(policyEvent.args.clone, deployer)
    })

    describe("Deployment", () => {
        it("should be deployed correctly", async () => {
            expect(policy).to.not.eq(undefined)
            expect(await checker.criterionHats(hatId)).to.eq(true)
            expect(await checker.criterionHats(thirdHatId)).to.eq(true)
            expect(await checker.hats()).to.eq(mockHatsAddress)
        })
    })

    describe("Policy", () => {
        it("should set guarded target correctly", async () => {
            await policy.setTarget(target).then((tx) => tx.wait())

            expect(await policy.guarded()).to.eq(target)
        })

        it("should return trait properly", async () => {
            expect(await policy.trait()).to.eq("Hats")
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

        it("should fail to enforce a user if they pass a non-criterion hat", async () => {
            await expect(
                policy.connect(target).enforce(subject, AbiCoder.defaultAbiCoder().encode(["uint256"], [secondHatId]))
            ).to.be.revertedWithCustomError(checker, "NotCriterionHat")
        })

        it("should enforce a user if the function is called with the valid data", async () => {
            const tx = await policy
                .connect(target)
                .enforce(subject, AbiCoder.defaultAbiCoder().encode(["uint256"], [hatId]))

            const receipt = await tx.wait()

            expect(receipt?.status).to.eq(1)
        })

        it("should fail to enforce a user if they do not own a criterion hat", async () => {
            await expect(
                policy.connect(target).enforce(notSubject, AbiCoder.defaultAbiCoder().encode(["uint256"], [thirdHatId]))
            ).to.be.revertedWithCustomError(checker, "NotWearingCriterionHat")
        })

        it("should prevent enforcing twice", async () => {
            await expect(
                policy.connect(target).enforce(subject, AbiCoder.defaultAbiCoder().encode(["uint256"], [hatId]))
            ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
        })
    })
})
