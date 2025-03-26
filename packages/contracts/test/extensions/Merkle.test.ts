import { StandardMerkleTree } from "@openzeppelin/merkle-tree"
import { expect } from "chai"
import { Signer, ZeroAddress, AbiCoder, encodeBytes32String } from "ethers"
import { ethers } from "hardhat"

import {
    MerkleProofChecker__factory as MerkleProofCheckerFactory,
    MerkleProofPolicy__factory as MerkleProofPolicyFactory,
    MerkleProofChecker,
    MerkleProofPolicy
} from "../../typechain-types"

describe("MerkleProof", () => {
    let policy: MerkleProofPolicy
    let checker: MerkleProofChecker
    let deployer: Signer
    let subject: Signer
    let target: Signer
    let notSubject: Signer

    let tree: StandardMerkleTree<string[]>
    let validProof: string[]

    const allowedAddresses = [
        ["0x2fbca3862a7d99486c61e0275b6f5660180fb1b3"],
        ["0x70564145fa8e8a15348ef0190e6b7c07a2120462"],
        ["0x27cfc88640089f340aeaec182baff0ddf15b1b37"],
        ["0xccde65cf4e39a2d28b50e3030fdab60c463fe215"],
        ["0x9bae2cfa33280a8332da9a3bd589f91935b12804"]
    ]

    const invalidRoot = encodeBytes32String("")
    const invalidProof = ["0x0000000000000000000000000000000000000000000000000000000000000000"]

    before(async () => {
        ;[deployer, subject, target, notSubject] = await ethers.getSigners()

        const subjectAddress = await subject.getAddress()

        allowedAddresses.push([subjectAddress])
        tree = StandardMerkleTree.of(allowedAddresses, ["address"])
        validProof = tree.getProof([subjectAddress])

        const CheckerFactory = await ethers.getContractFactory("MerkleProofCheckerFactory")
        const checkerFactory = await CheckerFactory.connect(deployer).deploy()

        const PolicyFactory = await ethers.getContractFactory("MerkleProofPolicyFactory")
        const policyFactory = await PolicyFactory.connect(deployer).deploy()

        const checkerTx = await checkerFactory.deploy(tree.root)
        const checkerReceipt = await checkerTx.wait()

        const checkerDeployEvent = CheckerFactory.interface.parseLog(
            checkerReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        checker = MerkleProofCheckerFactory.connect(checkerDeployEvent.args.clone, deployer)

        const policyTx = await policyFactory.deploy(checkerDeployEvent.args.clone)
        const policyReceipt = await policyTx.wait()
        const policyEvent = PolicyFactory.interface.parseLog(
            policyReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        policy = MerkleProofPolicyFactory.connect(policyEvent.args.clone, deployer)
    })

    describe("Deployment", () => {
        it("should be deployed correctly", async () => {
            expect(policy).to.not.eq(undefined)
            expect(await checker.root()).to.eq(tree.root)
        })

        it("should fail to deploy when the root is not valid", async () => {
            const CheckerFactory = await ethers.getContractFactory("MerkleProofCheckerFactory")
            const checkerFactory = await CheckerFactory.connect(deployer).deploy()

            await expect(checkerFactory.deploy(invalidRoot)).to.be.revertedWithCustomError(checker, "InvalidRoot")
        })
    })

    describe("Policy", () => {
        it("should set guarded target correctly", async () => {
            await policy.setTarget(target).then((tx) => tx.wait())

            expect(await policy.guarded()).to.eq(target)
        })

        it("should return trait properly", async () => {
            expect(await policy.trait()).to.eq("MerkleProof")
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

        it("should throw when the proof is invalid", async () => {
            await expect(
                policy
                    .connect(target)
                    .enforce(subject, AbiCoder.defaultAbiCoder().encode(["bytes32[]"], [invalidProof]))
            ).to.be.revertedWithCustomError(checker, "InvalidProof")
        })

        it("should enforce a user if the function is called with the valid data", async () => {
            const tx = await policy
                .connect(target)
                .enforce(subject, AbiCoder.defaultAbiCoder().encode(["bytes32[]"], [validProof]))

            const receipt = await tx.wait()

            expect(receipt?.status).to.eq(1)
        })

        it("should prevent enforcing twice", async () => {
            await expect(
                policy.connect(target).enforce(subject, AbiCoder.defaultAbiCoder().encode(["bytes32[]"], [validProof]))
            ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
        })
    })
})
