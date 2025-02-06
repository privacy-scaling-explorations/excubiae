import { AbiCoder, Signer, ZeroAddress, ZeroHash } from "ethers"
import { ethers } from "hardhat"
import { expect } from "chai"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import {
    NFT__factory,
    BaseERC721Checker__factory,
    BaseERC721Policy__factory,
    BaseERC721CheckerFactory__factory,
    BaseERC721PolicyFactory__factory,
    NFT,
    BaseERC721Checker,
    BaseERC721Policy,
    BaseERC721CheckerFactory,
    BaseERC721PolicyFactory,
    IERC721Errors,
    BaseVoting__factory,
    BaseVoting
} from "../typechain-types"

/* eslint-disable @typescript-eslint/no-shadow */
describe("Base", () => {
    describe("Checker", () => {
        async function deployBaseCheckerFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFT: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721CheckerFactory__factory =
                await ethers.getContractFactory("BaseERC721CheckerFactory")

            const nft: NFT = await NFT.deploy()
            const factory: BaseERC721CheckerFactory = await BaseERC721CheckerFactory.connect(deployer).deploy()

            const tx = await factory.deploy(await nft.getAddress())
            const receipt = await tx.wait()
            const event = BaseERC721CheckerFactory.interface.parseLog(
                receipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const checker: BaseERC721Checker = BaseERC721Checker__factory.connect(event.args.clone, deployer)

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                nft,
                checker,
                factory,
                deployer,
                target,
                subjectAddress,
                notOwnerAddress,
                validEncodedNFTId,
                invalidEncodedNFTId
            }
        }

        describe("initialize", () => {
            it("deploy and initialize correctly", async () => {
                const { checker } = await loadFixture(deployBaseCheckerFixture)

                expect(checker).to.not.eq(undefined)
                expect(await checker.initialized()).to.be.eq(true)
            })

            it("revert when already initialized", async () => {
                const { checker, deployer } = await loadFixture(deployBaseCheckerFixture)

                await expect(checker.connect(deployer).initialize()).to.be.revertedWithCustomError(
                    checker,
                    "AlreadyInitialized"
                )
            })
        })

        describe("getAppendedBytes", () => {
            it("append bytes correctly", async () => {
                const { checker, nft } = await loadFixture(deployBaseCheckerFixture)

                const appendedBytes = await checker.getAppendedBytes.staticCall()

                const expectedBytes = AbiCoder.defaultAbiCoder()
                    .encode(["address"], [await nft.getAddress()])
                    .toLowerCase()

                expect(appendedBytes).to.equal(expectedBytes)
            })
        })

        describe("check", () => {
            it("reverts when evidence is invalid", async () => {
                const { nft, checker, target, subjectAddress, invalidEncodedNFTId } =
                    await loadFixture(deployBaseCheckerFixture)

                await expect(
                    checker.connect(target).check(subjectAddress, [invalidEncodedNFTId])
                ).to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
            })

            it("returns false when subject not owner", async () => {
                const { checker, target, notOwnerAddress, validEncodedNFTId } =
                    await loadFixture(deployBaseCheckerFixture)

                expect(await checker.connect(target).check(notOwnerAddress, [validEncodedNFTId])).to.be.equal(false)
            })

            it("succeeds when valid", async () => {
                const { checker, target, subjectAddress, validEncodedNFTId } =
                    await loadFixture(deployBaseCheckerFixture)

                expect(await checker.connect(target).check(subjectAddress, [validEncodedNFTId])).to.be.equal(true)
            })
        })
    })

    describe("Policy", () => {
        async function deployBasePolicyFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFT: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721CheckerFactory__factory =
                await ethers.getContractFactory("BaseERC721CheckerFactory")
            const BaseERC721PolicyFactory: BaseERC721PolicyFactory__factory =
                await ethers.getContractFactory("BaseERC721PolicyFactory")

            const nft: NFT = await NFT.deploy()
            const iERC721Errors: IERC721Errors = await ethers.getContractAt("IERC721Errors", await nft.getAddress())

            const checkerFactory: BaseERC721CheckerFactory = await BaseERC721CheckerFactory.connect(deployer).deploy()
            const policyFactory: BaseERC721PolicyFactory = await BaseERC721PolicyFactory.connect(deployer).deploy()

            const checkerTx = await checkerFactory.deploy(await nft.getAddress())
            const checkerTxReceipt = await checkerTx.wait()
            const checkerCloneDeployedEvent = BaseERC721CheckerFactory.interface.parseLog(
                checkerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const checker: BaseERC721Checker = BaseERC721Checker__factory.connect(
                checkerCloneDeployedEvent.args.clone,
                deployer
            )

            const policyTx = await policyFactory.deploy(await checker.getAddress())
            const policyTxReceipt = await policyTx.wait()
            const policyCloneDeployedEvent = BaseERC721PolicyFactory.interface.parseLog(
                policyTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const policy = BaseERC721Policy__factory.connect(
                policyCloneDeployedEvent.args.clone,
                deployer
            ) as BaseERC721Policy

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                iERC721Errors,
                nft,
                checker,
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

        describe("initialize", () => {
            it("deploy and initialize correctly", async () => {
                const { policy } = await loadFixture(deployBasePolicyFixture)

                expect(policy).to.not.eq(undefined)
                expect(await policy.initialized()).to.be.eq(true)
            })

            it("revert when already initialized", async () => {
                const { policy, deployer } = await loadFixture(deployBasePolicyFixture)

                await expect(policy.connect(deployer).initialize()).to.be.revertedWithCustomError(
                    policy,
                    "AlreadyInitialized"
                )
            })
        })

        describe("getAppendedBytes", () => {
            it("append bytes correctly", async () => {
                const { policy, checker, deployer } = await loadFixture(deployBasePolicyFixture)

                const appendedBytes = await policy.getAppendedBytes.staticCall()

                const expectedBytes = AbiCoder.defaultAbiCoder()
                    .encode(["address", "address"], [await deployer.getAddress(), await checker.getAddress()])
                    .toLowerCase()

                expect(appendedBytes).to.equal(expectedBytes)
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
                const { policy, target } = await loadFixture(deployBasePolicyFixture)
                const targetAddress = await target.getAddress()
                const tx = await policy.setTarget(targetAddress)
                const receipt = await tx.wait()
                const event = policy.interface.parseLog(
                    receipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        target: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.target).to.eq(targetAddress)
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

                await expect(policy.connect(subject).enforce(subjectAddress, [ZeroHash])).to.be.revertedWithCustomError(
                    policy,
                    "TargetOnly"
                )
            })

            it("reverts when evidence invalid", async () => {
                const { iERC721Errors, policy, target, subjectAddress, invalidEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)

                await policy.setTarget(await target.getAddress())

                await expect(
                    policy.connect(target).enforce(subjectAddress, [invalidEncodedNFTId])
                ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
            })

            it("reverts when check fails", async () => {
                const { policy, target, notOwnerAddress, validEncodedNFTId } =
                    await loadFixture(deployBasePolicyFixture)

                await policy.setTarget(await target.getAddress())

                expect(
                    policy.connect(target).enforce(notOwnerAddress, [validEncodedNFTId])
                ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
            })

            it("enforces successfully", async () => {
                const { policy, target, subjectAddress, validEncodedNFTId } = await loadFixture(deployBasePolicyFixture)
                const targetAddress = await target.getAddress()

                await policy.setTarget(await target.getAddress())

                const tx = await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId])
                const receipt = await tx.wait()
                const event = policy.interface.parseLog(
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
                expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
            })
        })
    })

    describe("Voting", () => {
        async function deployBaseVotingFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFT: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721CheckerFactory__factory =
                await ethers.getContractFactory("BaseERC721CheckerFactory")
            const BaseERC721PolicyFactory: BaseERC721PolicyFactory__factory =
                await ethers.getContractFactory("BaseERC721PolicyFactory")
            const BaseVoting: BaseVoting__factory = await ethers.getContractFactory("BaseVoting")

            const nft: NFT = await NFT.deploy()
            const iERC721Errors: IERC721Errors = await ethers.getContractAt("IERC721Errors", await nft.getAddress())

            const checkerFactory: BaseERC721CheckerFactory = await BaseERC721CheckerFactory.connect(deployer).deploy()
            const policyFactory: BaseERC721PolicyFactory = await BaseERC721PolicyFactory.connect(deployer).deploy()

            const checkerTx = await checkerFactory.deploy(await nft.getAddress())
            const checkerTxReceipt = await checkerTx.wait()
            const checkerCloneDeployedEvent = BaseERC721CheckerFactory.interface.parseLog(
                checkerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const checker: BaseERC721Checker = BaseERC721Checker__factory.connect(
                checkerCloneDeployedEvent.args.clone,
                deployer
            )

            const policyTx = await policyFactory.deploy(await checker.getAddress())
            const policyTxReceipt = await policyTx.wait()
            const policyCloneDeployedEvent = BaseERC721PolicyFactory.interface.parseLog(
                policyTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const policy = BaseERC721Policy__factory.connect(
                policyCloneDeployedEvent.args.clone,
                deployer
            ) as BaseERC721Policy

            const baseVoting: BaseVoting = await BaseVoting.connect(deployer).deploy(await policy.getAddress())

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validNFTId = 0
            const invalidNFTId = 1
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [validNFTId])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [invalidNFTId])

            return {
                iERC721Errors,
                nft,
                checker,
                policy,
                baseVoting,
                subject,
                deployer,
                target,
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
                const { baseVoting, subject } = await loadFixture(deployBaseVotingFixture)

                expect(baseVoting).to.not.eq(undefined)
                expect(await baseVoting.registered(subject)).to.be.eq(false)
                expect(await baseVoting.hasVoted(subject)).to.be.eq(false)
            })
        })

        describe("register", () => {
            it("reverts when caller not target", async () => {
                const { baseVoting, policy, notOwner, validNFTId } = await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await notOwner.getAddress())

                await expect(baseVoting.connect(notOwner).register(validNFTId)).to.be.revertedWithCustomError(
                    policy,
                    "TargetOnly"
                )
            })

            it("reverts when evidence invalid", async () => {
                const { iERC721Errors, baseVoting, policy, subject, invalidNFTId } =
                    await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await baseVoting.getAddress())

                await expect(baseVoting.connect(subject).register(invalidNFTId)).to.be.revertedWithCustomError(
                    iERC721Errors,
                    "ERC721NonexistentToken"
                )
            })

            it("reverts when check fails", async () => {
                const { baseVoting, policy, notOwner, validNFTId } = await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await baseVoting.getAddress())

                await expect(baseVoting.connect(notOwner).register(validNFTId)).to.be.revertedWithCustomError(
                    policy,
                    "UnsuccessfulCheck"
                )
            })

            it("registers successfully", async () => {
                const { baseVoting, policy, subject, validNFTId, subjectAddress } =
                    await loadFixture(deployBaseVotingFixture)
                const targetAddress = await baseVoting.getAddress()

                await policy.setTarget(targetAddress)

                const tx = await baseVoting.connect(subject).register(validNFTId)
                const receipt = await tx.wait()
                const event = baseVoting.interface.parseLog(
                    receipt?.logs[1] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect(await baseVoting.registered(subjectAddress)).to.be.equal(true)
                expect(await baseVoting.hasVoted(subjectAddress)).to.be.equal(false)
            })
        })

        describe("vote", () => {
            it("reverts when not registered", async () => {
                const { baseVoting, policy, subject } = await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await baseVoting.getAddress())

                await expect(baseVoting.connect(subject).vote(0)).to.be.revertedWithCustomError(
                    baseVoting,
                    "NotRegistered"
                )
            })

            it("reverts when option invalid", async () => {
                const { baseVoting, policy, subject, validNFTId } = await loadFixture(deployBaseVotingFixture)

                await policy.setTarget(await baseVoting.getAddress())
                await baseVoting.connect(subject).register(validNFTId)

                await expect(baseVoting.connect(subject).vote(3)).to.be.revertedWithCustomError(
                    baseVoting,
                    "InvalidOption"
                )
            })

            it("votes successfully", async () => {
                const { baseVoting, policy, subject, subjectAddress, validNFTId } =
                    await loadFixture(deployBaseVotingFixture)
                const option = 0

                await policy.setTarget(await baseVoting.getAddress())
                await baseVoting.connect(subject).register(validNFTId)

                const tx = await baseVoting.connect(subject).vote(option)
                const receipt = await tx.wait()
                const event = baseVoting.interface.parseLog(
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
                expect(await baseVoting.registered(subjectAddress)).to.be.equal(true)
                expect(await baseVoting.hasVoted(subjectAddress)).to.be.equal(true)
            })

            it("reverts when already voted", async () => {
                const { baseVoting, policy, subject, validNFTId } = await loadFixture(deployBaseVotingFixture)
                const targetAddress = await baseVoting.getAddress()

                await policy.setTarget(targetAddress)
                await baseVoting.connect(subject).register(validNFTId)

                await baseVoting.connect(subject).vote(0)

                await expect(baseVoting.connect(subject).vote(1)).to.be.revertedWithCustomError(
                    baseVoting,
                    "AlreadyVoted"
                )
            })
        })

        describe("end to end", () => {
            it("completes full voting flow", async () => {
                const [deployer]: Signer[] = await ethers.getSigners()

                const NFT: NFT__factory = await ethers.getContractFactory("NFT")
                const BaseERC721CheckerFactory: BaseERC721CheckerFactory__factory =
                    await ethers.getContractFactory("BaseERC721CheckerFactory")
                const BaseERC721PolicyFactory: BaseERC721PolicyFactory__factory =
                    await ethers.getContractFactory("BaseERC721PolicyFactory")
                const BaseVoting: BaseVoting__factory = await ethers.getContractFactory("BaseVoting")

                const nft: NFT = await NFT.deploy()

                const checkerFactory: BaseERC721CheckerFactory =
                    await BaseERC721CheckerFactory.connect(deployer).deploy()
                const policyFactory: BaseERC721PolicyFactory = await BaseERC721PolicyFactory.connect(deployer).deploy()

                const checkerTx = await checkerFactory.deploy(await nft.getAddress())
                const checkerTxReceipt = await checkerTx.wait()
                const checkerCloneDeployedEvent = BaseERC721CheckerFactory.interface.parseLog(
                    checkerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        clone: string
                    }
                }

                const checker: BaseERC721Checker = BaseERC721Checker__factory.connect(
                    checkerCloneDeployedEvent.args.clone,
                    deployer
                )

                const policyTx = await policyFactory.deploy(await checker.getAddress())
                const policyTxReceipt = await policyTx.wait()
                const policyCloneDeployedEvent = BaseERC721PolicyFactory.interface.parseLog(
                    policyTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        clone: string
                    }
                }

                const policy = BaseERC721Policy__factory.connect(
                    policyCloneDeployedEvent.args.clone,
                    deployer
                ) as BaseERC721Policy

                const baseVoting: BaseVoting = await BaseVoting.connect(deployer).deploy(await policy.getAddress())

                // set the target.
                await policy.setTarget(await baseVoting.getAddress())

                for (const [tokenId, voter] of (await ethers.getSigners()).entries()) {
                    const voterAddress = await voter.getAddress()

                    // mint for voter.
                    await nft.connect(deployer).mint(voterAddress)

                    // register.
                    await baseVoting.connect(voter).register(tokenId)

                    // vote.
                    await baseVoting.connect(voter).vote(tokenId % 2)

                    expect(await baseVoting.hasVoted(voter)).to.be.equal(true)
                }
            })
        })
    })
})
