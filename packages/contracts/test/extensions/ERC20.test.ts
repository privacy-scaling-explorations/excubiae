import { expect } from "chai"
import { AbiCoder, Signer, ZeroAddress } from "ethers"
import { ethers } from "hardhat"

import {
    ERC20Policy__factory as ERC20PolicyFactory,
    ERC20Policy,
    MockERC20Votes,
    ERC20Checker,
    ERC20Checker__factory as ERC20CheckerFactory
} from "../../typechain-types"

describe("ERC20", () => {
    let policy: ERC20Policy
    let checker: ERC20Checker
    let mockERC20Votes: MockERC20Votes
    let deployer: Signer
    let subject: Signer
    let target: Signer
    let notSubject: Signer

    const threshold = 5n

    before(async () => {
        ;[deployer, subject, target, notSubject] = await ethers.getSigners()

        const MockERC20VotesFactory = await ethers.getContractFactory("MockERC20Votes")
        mockERC20Votes = await MockERC20VotesFactory.connect(deployer).deploy("MockERC20Votes", "MKV")
        const mockERC20VotesAddress = await mockERC20Votes.getAddress()

        await mockERC20Votes.transfer(await subject.getAddress(), threshold + 1n)
        await mockERC20Votes.transfer(await notSubject.getAddress(), threshold - 1n)

        const CheckerFactory = await ethers.getContractFactory("ERC20CheckerFactory")
        const checkerFactory = await CheckerFactory.connect(deployer).deploy()

        const PolicyFactory = await ethers.getContractFactory("ERC20PolicyFactory")
        const policyFactory = await PolicyFactory.connect(deployer).deploy()

        const checkerTx = await checkerFactory.deploy(mockERC20VotesAddress, threshold)
        const checkerReceipt = await checkerTx.wait()

        const checkerDeployEvent = CheckerFactory.interface.parseLog(
            checkerReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        const policyTx = await policyFactory.deploy(checkerDeployEvent.args.clone)
        const policyReceipt = await policyTx.wait()
        const policyEvent = PolicyFactory.interface.parseLog(
            policyReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        policy = ERC20PolicyFactory.connect(policyEvent.args.clone, deployer)
        checker = ERC20CheckerFactory.connect(checkerDeployEvent.args.clone, deployer)
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
            expect(await policy.trait()).to.eq("ERC20")
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

        it("should enforce a user if the function is called with the valid data", async () => {
            const tx = await policy.connect(target).enforce(subject, AbiCoder.defaultAbiCoder().encode([], []))

            const receipt = await tx.wait()

            expect(receipt?.status).to.eq(1)
        })

        it("should not enforce twice", async () => {
            await expect(
                policy.connect(target).enforce(subject, AbiCoder.defaultAbiCoder().encode([], []))
            ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
        })

        it("should revert when the balance is too low", async () => {
            await expect(
                policy.connect(target).enforce(notSubject, AbiCoder.defaultAbiCoder().encode([], []))
            ).to.be.revertedWithCustomError(checker, "BalanceTooLow")
        })
    })
})
