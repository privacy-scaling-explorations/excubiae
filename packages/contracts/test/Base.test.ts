import { expect } from "chai"
import { ethers } from "hardhat"
import { AbiCoder, Signer, ZeroAddress, ZeroHash } from "ethers"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import {
    BaseERC721Checker,
    BaseERC721Checker__factory,
    BaseERC721Policy,
    BaseERC721Policy__factory,
    BaseERC721CheckerHarness,
    BaseERC721CheckerHarness__factory,
    BaseERC721PolicyHarness,
    BaseERC721PolicyHarness__factory,
    NFT,
    NFT__factory,
    IERC721Errors,
    BaseVoting__factory,
    BaseVoting
} from "../typechain-types"

describe("Base", () => {
    describe("Checker", () => {
        async function deployBaseCheckerFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721Checker__factory =
                await ethers.getContractFactory("BaseERC721Checker")
            const BaseERC721CheckerHarnessFactory: BaseERC721CheckerHarness__factory =
                await ethers.getContractFactory("BaseERC721CheckerHarness")

            const nft: NFT = await NFTFactory.deploy()
            const checker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy(
                await nft.getAddress()
            )
            const checkerHarness: BaseERC721CheckerHarness = await BaseERC721CheckerHarnessFactory.connect(
                deployer
            ).deploy(await nft.getAddress())

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                nft,
                checker,
                checkerHarness,
                target,
                subjectAddress,
                notOwnerAddress,
                validNFTId,
                invalidNFTId
            }
        }

        describe("constructor", () => {
            it("deploys correctly", async () => {
                const { checker } = await loadFixture(deployBaseCheckerFixture)

                expect(checker).to.not.eq(undefined)
            })
        })

        describe("check", () => {
            it("reverts when evidence is invalid", async () => {
                const { nft, checker, target, subjectAddress, invalidNFTId } =
                    await loadFixture(deployBaseCheckerFixture)

                await expect(checker.connect(target).check(subjectAddress, invalidNFTId)).to.be.revertedWithCustomError(
                    nft,
                    "ERC721NonexistentToken"
                )
            })

            it("returns false when subject not owner", async () => {
                const { checker, target, notOwnerAddress, validNFTId } = await loadFixture(deployBaseCheckerFixture)

                expect(await checker.connect(target).check(notOwnerAddress, validNFTId)).to.be.equal(false)
            })

            it("succeeds when valid", async () => {
                const { checker, target, subjectAddress, validNFTId } = await loadFixture(deployBaseCheckerFixture)

                expect(await checker.connect(target).check(subjectAddress, validNFTId)).to.be.equal(true)
            })
        })

        describe("internal check", () => {
            it("reverts when evidence is invalid", async () => {
                const { nft, checkerHarness, target, subjectAddress, invalidNFTId } =
                    await loadFixture(deployBaseCheckerFixture)

                await expect(
                    checkerHarness.connect(target).exposed__check(subjectAddress, invalidNFTId)
                ).to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
            })

            it("returns false when subject not owner", async () => {
                const { checkerHarness, target, notOwnerAddress, validNFTId } =
                    await loadFixture(deployBaseCheckerFixture)

                expect(await checkerHarness.connect(target).exposed__check(notOwnerAddress, validNFTId)).to.be.equal(
                    false
                )
            })

            it("succeeds when valid", async () => {
                const { checkerHarness, target, subjectAddress, validNFTId } =
                    await loadFixture(deployBaseCheckerFixture)

                expect(await checkerHarness.connect(target).exposed__check(subjectAddress, validNFTId)).to.be.equal(
                    true
                )
            })
        })
    })

    describe("Policy", () => {
        async function deployBasePolicyFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721Checker__factory =
                await ethers.getContractFactory("BaseERC721Checker")
            const BaseERC721PolicyFactory: BaseERC721Policy__factory =
                await ethers.getContractFactory("BaseERC721Policy")
            const BaseERC721PolicyHarnessFactory: BaseERC721PolicyHarness__factory =
                await ethers.getContractFactory("BaseERC721PolicyHarness")

            const nft: NFT = await NFTFactory.deploy()
            const iERC721Errors: IERC721Errors = await ethers.getContractAt("IERC721Errors", await nft.getAddress())

            const checker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy(
                await nft.getAddress()
            )
            const policy: BaseERC721Policy = await BaseERC721PolicyFactory.connect(deployer).deploy(
                await checker.getAddress()
            )
            const policyHarness: BaseERC721PolicyHarness = await BaseERC721PolicyHarnessFactory.connect(
                deployer
            ).deploy(await checker.getAddress())

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                iERC721Errors,
                BaseERC721PolicyFactory,
                nft,
                policyHarness,
                policy,
                subject,
                deployer,
                target,
                notOwner,
                subjectAddress,
                notOwnerAddress,
                validEncodedNFTId,
                invalidEncodedNFTId
            }
        }

        describe("constructor", () => {
            it("deploys correctly", async () => {
                const { policy } = await loadFixture(deployBasePolicyFixture)

                expect(policy).to.not.eq(undefined)
            })
        })

        describe("trait", () => {
            it("returns correct value", async () => {
                const { policy } = await loadFixture(deployBasePolicyFixture)

                expect(await policy.trait()).to.be.eq("BaseERC721")
            })
        })

        describe("setTarget", () => {
            it("reverts when caller not owner", async () => {
                const { policy, notOwner, target } = await loadFixture(deployBasePolicyFixture)

                await expect(
                    policy.connect(notOwner).setTarget(await target.getAddress())
                ).to.be.revertedWithCustomError(policy, "OwnableUnauthorizedAccount")
            })

            it("reverts when zero address", async () => {
                const { policy, deployer } = await loadFixture(deployBasePolicyFixture)

                await expect(policy.connect(deployer).setTarget(ZeroAddress)).to.be.revertedWithCustomError(
                    policy,
                    "ZeroAddress"
                )
            })

            it("sets target correctly", async () => {
                const { policy, target, BaseERC721PolicyFactory } = await loadFixture(deployBasePolicyFixture)
                const targetAddress = await target.getAddress()

                const tx = await policy.setTarget(targetAddress)
                const receipt = await tx.wait()
                const event = BaseERC721PolicyFactory.interface.parseLog(
                    receipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        target: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.target).to.eq(targetAddress)
                expect(await policy.getTarget()).to.eq(targetAddress)
            })

            it("reverts when already set", async () => {
                const { policy, target } = await loadFixture(deployBasePolicyFixture)
                const targetAddress = await target.getAddress()

                await policy.setTarget(targetAddress)

                await expect(policy.setTarget(targetAddress)).to.be.revertedWithCustomError(policy, "TargetAlreadySet")
            })
        })

        describe("enforce", () => {
            it("reverts when caller not target", async () => {
                const { policy, subject, target, subjectAddress } = await loadFixture(deployBasePolicyFixture)

                await policy.setTarget(await target.getAddress())

                await expect(policy.connect(subject).enforce(subjectAddress, ZeroHash)).to.be.revertedWithCustomError(
                    policy,
                    "TargetOnly"
                )
            })

            it("reverts when evidence invalid", async () => {
                const { iERC721Errors, policy, target, subjectAddress, invalidEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)

                await policy.setTarget(await target.getAddress())

                await expect(
                    policy.connect(target).enforce(subjectAddress, invalidEncodedNFTId)
                ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
            })

            it("reverts when check fails", async () => {
                const { policy, target, notOwnerAddress, validEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)

                await policy.setTarget(await target.getAddress())

                expect(
                    policy.connect(target).enforce(notOwnerAddress, validEncodedNFTId)
                ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
            })

            it("enforces successfully", async () => {
                const { BaseERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)
                const targetAddress = await target.getAddress()

                await policy.setTarget(await target.getAddress())

                const tx = await policy.connect(target).enforce(subjectAddress, validEncodedNFTId)
                const receipt = await tx.wait()
                const event = BaseERC721PolicyFactory.interface.parseLog(
                    receipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        subject: string
                        target: string
                        evidence: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.subject).to.eq(subjectAddress)
                expect(event.args.target).to.eq(targetAddress)
                expect(event.args.evidence).to.eq(validEncodedNFTId)
                expect(await policy.enforced(targetAddress, subjectAddress)).to.be.equal(true)
            })

            it("reverts when already enforced", async () => {
                const { policy, target, subjectAddress, validEncodedNFTId } = await loadFixture(deployBasePolicyFixture)

                await policy.setTarget(await target.getAddress())

                await policy.connect(target).enforce(subjectAddress, validEncodedNFTId)

                await expect(
                    policy.connect(target).enforce(subjectAddress, validEncodedNFTId)
                ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
            })
        })

        describe("internal enforce", () => {
            it("reverts when caller not target", async () => {
                const { policyHarness, subject, target, subjectAddress } = await loadFixture(deployBasePolicyFixture)

                await policyHarness.setTarget(await target.getAddress())

                await expect(
                    policyHarness.connect(subject).exposed__enforce(subjectAddress, ZeroHash)
                ).to.be.revertedWithCustomError(policyHarness, "TargetOnly")
            })

            it("reverts when evidence invalid", async () => {
                const { iERC721Errors, policyHarness, target, subjectAddress, invalidEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)

                await policyHarness.setTarget(await target.getAddress())

                await expect(
                    policyHarness.connect(target).exposed__enforce(subjectAddress, invalidEncodedNFTId)
                ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
            })

            it("reverts when check fails", async () => {
                const { policyHarness, target, notOwnerAddress, validEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)

                await policyHarness.setTarget(await target.getAddress())

                expect(
                    policyHarness.connect(target).exposed__enforce(notOwnerAddress, validEncodedNFTId)
                ).to.be.revertedWithCustomError(policyHarness, "UnsuccessfulCheck")
            })

            it("enforces successfully", async () => {
                const { BaseERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)
                const targetAddress = await target.getAddress()

                await policyHarness.setTarget(await target.getAddress())

                const tx = await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId)
                const receipt = await tx.wait()
                const event = BaseERC721PolicyFactory.interface.parseLog(
                    receipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        subject: string
                        target: string
                        evidence: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.subject).to.eq(subjectAddress)
                expect(event.args.target).to.eq(targetAddress)
                expect(event.args.evidence).to.eq(validEncodedNFTId)
                expect(await policyHarness.enforced(targetAddress, subjectAddress)).to.be.equal(true)
            })

            it("reverts when already enforced", async () => {
                const { policyHarness, target, subjectAddress, validEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)

                await policyHarness.setTarget(await target.getAddress())

                await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId)

                await expect(
                    policyHarness.connect(target).enforce(subjectAddress, validEncodedNFTId)
                ).to.be.revertedWithCustomError(policyHarness, "AlreadyEnforced")
            })
        })
    })

    describe("Voting", () => {
        async function deployBaseVotingFixture() {
            const [deployer, subject, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721Checker__factory =
                await ethers.getContractFactory("BaseERC721Checker")
            const BaseERC721PolicyFactory: BaseERC721Policy__factory =
                await ethers.getContractFactory("BaseERC721Policy")
            const BaseVotingFactory: BaseVoting__factory = await ethers.getContractFactory("BaseVoting")

            const nft: NFT = await NFTFactory.deploy()
            const iERC721Errors: IERC721Errors = await ethers.getContractAt("IERC721Errors", await nft.getAddress())

            const checker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy(
                await nft.getAddress()
            )
            const policy: BaseERC721Policy = await BaseERC721PolicyFactory.connect(deployer).deploy(
                await checker.getAddress()
            )
            const voting: BaseVoting = await BaseVotingFactory.connect(deployer).deploy(await policy.getAddress())

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validNFTId = 0
            const invalidNFTId = 1
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [validNFTId])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [invalidNFTId])

            return {
                iERC721Errors,
                BaseVotingFactory,
                nft,
                voting,
                policy,
                subject,
                deployer,
                notOwner,
                subjectAddress,
                notOwnerAddress,
                validNFTId,
                invalidNFTId,
                validEncodedNFTId,
                invalidEncodedNFTId
            }
        }

        describe("constructor", () => {
            it("deploys correctly", async () => {
                const { voting } = await loadFixture(deployBaseVotingFixture)

                expect(voting).to.not.eq(undefined)
            })
        })

        describe("register", () => {
            it("reverts when caller not target", async () => {
                const { voting, policy, notOwner, validNFTId } = await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await notOwner.getAddress())

                await expect(voting.connect(notOwner).register(validNFTId)).to.be.revertedWithCustomError(
                    policy,
                    "TargetOnly"
                )
            })

            it("reverts when evidence invalid", async () => {
                const { iERC721Errors, voting, policy, subject, invalidNFTId } =
                    await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await voting.getAddress())

                await expect(voting.connect(subject).register(invalidNFTId)).to.be.revertedWithCustomError(
                    iERC721Errors,
                    "ERC721NonexistentToken"
                )
            })

            it("reverts when check fails", async () => {
                const { voting, policy, notOwner, validNFTId } = await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await voting.getAddress())

                await expect(voting.connect(notOwner).register(validNFTId)).to.be.revertedWithCustomError(
                    policy,
                    "UnsuccessfulCheck"
                )
            })

            it("registers successfully", async () => {
                const { BaseVotingFactory, voting, policy, subject, validNFTId, subjectAddress } =
                    await loadFixture(deployBaseVotingFixture)
                const targetAddress = await voting.getAddress()

                await policy.setTarget(targetAddress)

                const tx = await voting.connect(subject).register(validNFTId)
                const receipt = await tx.wait()
                const event = BaseVotingFactory.interface.parseLog(
                    receipt?.logs[1] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect(await policy.enforced(targetAddress, subjectAddress)).to.be.equal(true)
                expect(await voting.hasVoted(subjectAddress)).to.be.equal(false)
                expect(await voting.voteCounts(0)).to.be.equal(0)
                expect(await voting.voteCounts(1)).to.be.equal(0)
            })

            it("reverts when already registered", async () => {
                const { voting, policy, subject, validNFTId } = await loadFixture(deployBaseVotingFixture)
                const targetAddress = await voting.getAddress()

                await policy.setTarget(targetAddress)

                await voting.connect(subject).register(validNFTId)

                await expect(voting.connect(subject).register(validNFTId)).to.be.revertedWithCustomError(
                    policy,
                    "AlreadyEnforced"
                )
            })
        })

        describe("vote", () => {
            it("reverts when not registered", async () => {
                const { voting, policy, subject } = await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await voting.getAddress())

                await expect(voting.connect(subject).vote(0)).to.be.revertedWithCustomError(voting, "NotRegistered")
            })

            it("reverts when option invalid", async () => {
                const { voting, policy, subject, validNFTId } = await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await voting.getAddress())
                await voting.connect(subject).register(validNFTId)

                await expect(voting.connect(subject).vote(3)).to.be.revertedWithCustomError(voting, "InvalidOption")
            })

            it("votes successfully", async () => {
                const { BaseVotingFactory, voting, policy, subject, subjectAddress, validNFTId } =
                    await loadFixture(deployBaseVotingFixture)
                const option = 0

                await policy.setTarget(await voting.getAddress())
                await voting.connect(subject).register(validNFTId)

                const tx = await voting.connect(subject).vote(option)
                const receipt = await tx.wait()
                const event = BaseVotingFactory.interface.parseLog(
                    receipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                        option: number
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect(event.args.option).to.eq(option)
                expect(await voting.hasVoted(subjectAddress)).to.be.equal(true)
                expect(await voting.voteCounts(0)).to.be.equal(1)
                expect(await voting.voteCounts(1)).to.be.equal(0)
            })

            it("reverts when already voted", async () => {
                const { voting, policy, subject, validNFTId } = await loadFixture(deployBaseVotingFixture)
                const targetAddress = await voting.getAddress()

                await policy.setTarget(targetAddress)
                await voting.connect(subject).register(validNFTId)

                await voting.connect(subject).vote(0)

                await expect(voting.connect(subject).vote(1)).to.be.revertedWithCustomError(voting, "AlreadyVoted")
            })
        })

        describe("end to end", () => {
            it("completes full voting flow", async () => {
                const [deployer]: Signer[] = await ethers.getSigners()

                const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
                const BaseERC721CheckerFactory: BaseERC721Checker__factory =
                    await ethers.getContractFactory("BaseERC721Checker")
                const BaseERC721PolicyFactory: BaseERC721Policy__factory =
                    await ethers.getContractFactory("BaseERC721Policy")
                const BaseVotingFactory: BaseVoting__factory = await ethers.getContractFactory("BaseVoting")

                const nft: NFT = await NFTFactory.deploy()

                const checker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy(
                    await nft.getAddress()
                )
                const policy: BaseERC721Policy = await BaseERC721PolicyFactory.connect(deployer).deploy(
                    await checker.getAddress()
                )
                const voting: BaseVoting = await BaseVotingFactory.connect(deployer).deploy(await policy.getAddress())

                // set the target.
                await policy.setTarget(await voting.getAddress())

                for (const [tokenId, voter] of (await ethers.getSigners()).entries()) {
                    const voterAddress = await voter.getAddress()

                    // mint for voter.
                    await nft.connect(deployer).mint(voterAddress)

                    // register.
                    await voting.connect(voter).register(tokenId)

                    // vote.
                    await voting.connect(voter).vote(tokenId % 2)

                    expect(await voting.hasVoted(voter)).to.be.equal(true)
                }
            })
        })
    })
})
