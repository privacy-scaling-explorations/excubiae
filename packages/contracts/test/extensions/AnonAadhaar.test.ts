import { expect } from "chai"
import { AbiCoder, Signer, ZeroAddress } from "ethers"
import { ethers } from "hardhat"

import {
    AnonAadhaarChecker,
    AnonAadhaarChecker__factory as AnonAadhaarCheckerFactory,
    AnonAadhaarPolicy,
    AnonAadhaarPolicy__factory as AnonAadhaarPolicyFactory,
    MockAnonAadhaar
} from "../../typechain-types"

describe("AnonAadhaar", () => {
    let policy: AnonAadhaarPolicy
    let checker: AnonAadhaarChecker
    let mockAnonAadhaar: MockAnonAadhaar
    let deployer: Signer
    let subject: Signer
    let target: Signer
    let notSubject: Signer
    let signerAddressUint256: bigint
    let encodedProof: string

    // Define the constant nullifierSeed
    const nullifierSeed = 1234

    // Mock AnonAadhaar proof
    const mockProof = {
        timestamp: Math.floor(new Date().getTime() / 1000) - 2 * 60 * 60,
        nullifierSeed: nullifierSeed.toString(),
        nullifier: "7946664694698614794431553425553810756961743235367295886353548733878558886762",
        ageAbove18: "1",
        gender: "77",
        pincode: "110051",
        state: "452723500356",
        packedGroth16Proof: ["0", "1", "2", "3", "4", "5", "6", "7"]
    }

    before(async () => {
        ;[deployer, subject, target, notSubject] = await ethers.getSigners()

        const mockAnonAadhaarFactory = await ethers.getContractFactory("MockAnonAadhaar")
        mockAnonAadhaar = await mockAnonAadhaarFactory.connect(deployer).deploy()
        const mockAnonAadhaarAddress = await mockAnonAadhaar.getAddress()

        const CheckerFactory = await ethers.getContractFactory("AnonAadhaarCheckerFactory")
        const checkerFactory = await CheckerFactory.connect(deployer).deploy()

        const PolicyFactory = await ethers.getContractFactory("AnonAadhaarPolicyFactory")
        const policyFactory = await PolicyFactory.connect(deployer).deploy()

        const checkerTx = await checkerFactory.deploy(mockAnonAadhaarAddress, nullifierSeed.toString())
        const checkerReceipt = await checkerTx.wait()

        const checkerDeployEvent = CheckerFactory.interface.parseLog(
            checkerReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        checker = AnonAadhaarCheckerFactory.connect(checkerDeployEvent.args.clone, deployer)

        const policyTx = await policyFactory.deploy(checkerDeployEvent.args.clone)
        const policyReceipt = await policyTx.wait()
        const policyEvent = PolicyFactory.interface.parseLog(
            policyReceipt?.logs[0] as unknown as { topics: string[]; data: string }
        ) as unknown as {
            args: {
                clone: string
            }
        }

        policy = AnonAadhaarPolicyFactory.connect(policyEvent.args.clone, deployer)

        signerAddressUint256 = BigInt(await subject.getAddress())
        encodedProof = AbiCoder.defaultAbiCoder().encode(
            ["uint256", "uint256", "uint256", "uint256", "uint256[4]", "uint256[8]"],
            [
                mockProof.nullifierSeed,
                mockProof.nullifier,
                mockProof.timestamp,
                signerAddressUint256,
                [mockProof.ageAbove18, mockProof.gender, mockProof.pincode, mockProof.state],
                mockProof.packedGroth16Proof
            ]
        )
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
            expect(await policy.trait()).to.eq("AnonAadhaar")
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

        it("should revert if the nullifier seed is invalid", async () => {
            const invalidNullifierSeedProof = {
                ...mockProof,
                nullifierSeed: "5678"
            }

            const encodedInvalidNullifierSeedProof = AbiCoder.defaultAbiCoder().encode(
                ["uint256", "uint256", "uint256", "uint256", "uint256[4]", "uint256[8]"],
                [
                    invalidNullifierSeedProof.nullifierSeed,
                    invalidNullifierSeedProof.nullifier,
                    invalidNullifierSeedProof.timestamp,
                    signerAddressUint256,
                    [
                        invalidNullifierSeedProof.ageAbove18,
                        invalidNullifierSeedProof.gender,
                        invalidNullifierSeedProof.pincode,
                        invalidNullifierSeedProof.state
                    ],
                    invalidNullifierSeedProof.packedGroth16Proof
                ]
            )

            await expect(
                policy.connect(target).enforce(subject, encodedInvalidNullifierSeedProof)
            ).to.be.revertedWithCustomError(checker, "InvalidNullifierSeed")
        })

        it("should revert if the signal is invalid", async () => {
            const encodedInvalidProof = AbiCoder.defaultAbiCoder().encode(
                ["uint256", "uint256", "uint256", "uint256", "uint256[4]", "uint256[8]"],
                [
                    mockProof.nullifierSeed,
                    mockProof.nullifier,
                    mockProof.timestamp,
                    BigInt(ZeroAddress),
                    [mockProof.ageAbove18, mockProof.gender, mockProof.pincode, mockProof.state],
                    mockProof.packedGroth16Proof
                ]
            )
            await expect(policy.connect(target).enforce(subject, encodedInvalidProof)).to.be.revertedWithCustomError(
                checker,
                "InvalidSignal"
            )
        })

        it("should revert if the proof is invalid (mock)", async () => {
            await mockAnonAadhaar.flipValid()
            await expect(policy.connect(target).enforce(subject, encodedProof)).to.be.revertedWithCustomError(
                checker,
                "InvalidProof"
            )
            await mockAnonAadhaar.flipValid()
        })

        it("should enforce a user if the function is called with the valid data", async () => {
            const tx = await policy.connect(target).enforce(subject, encodedProof)

            const receipt = await tx.wait()

            expect(receipt?.status).to.eq(1)
        })

        it("should prevent enforcing twice", async () => {
            await expect(policy.connect(target).enforce(subject, encodedProof)).to.be.revertedWithCustomError(
                policy,
                "AlreadyEnforced"
            )
        })
    })
})
