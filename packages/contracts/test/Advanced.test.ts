import { AbiCoder, Signer, ZeroAddress, ZeroHash } from "ethers"
import { ethers } from "hardhat"
import { expect } from "chai"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import {
    NFT__factory,
    BaseERC721Checker__factory,
    BaseERC721CheckerFactory__factory,
    AdvancedERC721CheckerFactory__factory,
    NFT,
    BaseERC721Checker,
    BaseERC721CheckerFactory,
    AdvancedERC721CheckerFactory,
    IERC721Errors,
    AdvancedERC721Checker__factory,
    AdvancedERC721Checker,
    AdvancedERC721PolicyFactory__factory,
    AdvancedERC721PolicyFactory,
    AdvancedERC721Policy,
    AdvancedERC721Policy__factory,
    AdvancedVoting__factory,
    AdvancedVoting
} from "../typechain-types"

/* eslint-disable @typescript-eslint/no-shadow */
describe("Advanced", () => {
    describe("Checker", () => {
        async function deployAdvancedCheckerFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFT: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721CheckerFactory__factory =
                await ethers.getContractFactory("BaseERC721CheckerFactory")
            const AdvancedERC721CheckerFactory: AdvancedERC721CheckerFactory__factory =
                await ethers.getContractFactory("AdvancedERC721CheckerFactory")

            const signupNft: NFT = await NFT.deploy()
            const rewardNft: NFT = await NFT.deploy()

            const baseCheckerFactory: BaseERC721CheckerFactory =
                await BaseERC721CheckerFactory.connect(deployer).deploy()

            const baseCheckerTx = await baseCheckerFactory.deploy(await signupNft.getAddress())
            const baseCheckerTxReceipt = await baseCheckerTx.wait()
            const baseCheckerCloneDeployedEvent = BaseERC721CheckerFactory.interface.parseLog(
                baseCheckerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const baseChecker: BaseERC721Checker = BaseERC721Checker__factory.connect(
                baseCheckerCloneDeployedEvent.args.clone,
                deployer
            )

            const advancedCheckerFactory: AdvancedERC721CheckerFactory =
                await AdvancedERC721CheckerFactory.connect(deployer).deploy()

            const advancedCheckerTx = await advancedCheckerFactory.deploy(
                await signupNft.getAddress(),
                await rewardNft.getAddress(),
                await baseChecker.getAddress(),
                1,
                0,
                10
            )
            const advancedCheckerTxReceipt = await advancedCheckerTx.wait()
            const advancedCheckerCloneDeployedEvent = AdvancedERC721CheckerFactory.interface.parseLog(
                advancedCheckerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const advancedChecker: AdvancedERC721Checker = AdvancedERC721Checker__factory.connect(
                advancedCheckerCloneDeployedEvent.args.clone,
                deployer
            )

            // mint 0 for subject.
            await signupNft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                signupNft,
                rewardNft,
                baseChecker,
                advancedChecker,
                deployer,
                target,
                subject,
                subjectAddress,
                notOwnerAddress,
                validEncodedNFTId,
                invalidEncodedNFTId
            }
        }

        describe("initialize", () => {
            it("should deploy and initialize correctly", async () => {
                const { advancedChecker } = await loadFixture(deployAdvancedCheckerFixture)

                expect(advancedChecker).to.not.eq(undefined)
                expect(await advancedChecker.initialized()).to.be.eq(true)
            })

            it("should revert when already initialized", async () => {
                const { advancedChecker, deployer } = await loadFixture(deployAdvancedCheckerFixture)

                await expect(advancedChecker.connect(deployer).initialize()).to.be.revertedWithCustomError(
                    advancedChecker,
                    "AlreadyInitialized"
                )
            })
        })

        describe("getAppendedBytes", () => {
            it("should append bytes correctly", async () => {
                const { advancedChecker, signupNft, rewardNft, baseChecker } =
                    await loadFixture(deployAdvancedCheckerFixture)

                const appendedBytes = await advancedChecker.getAppendedBytes.staticCall()

                const expectedBytes = AbiCoder.defaultAbiCoder()
                    .encode(
                        ["address", "address", "address", "uint256", "uint256", "uint256"],
                        [
                            await signupNft.getAddress(),
                            await rewardNft.getAddress(),
                            await baseChecker.getAddress(),
                            1,
                            0,
                            10
                        ]
                    )
                    .toLowerCase()

                expect(appendedBytes).to.equal(expectedBytes)
            })
        })

        describe("check", () => {
            describe("pre check", () => {
                it("reverts when evidence invalid", async () => {
                    const { rewardNft, advancedChecker, target, subjectAddress, invalidEncodedNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    await expect(
                        advancedChecker.connect(target).check(subjectAddress, [invalidEncodedNFTId], 0)
                    ).to.be.revertedWithCustomError(rewardNft, "ERC721NonexistentToken")
                })

                it("returns false when not owner", async () => {
                    const { advancedChecker, target, notOwnerAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await advancedChecker.connect(target).check(notOwnerAddress, [validEncodedNFTId], 0)
                    ).to.be.equal(false)
                })

                it("succeeds when valid", async () => {
                    const { advancedChecker, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await advancedChecker.connect(target).check(subjectAddress, [validEncodedNFTId], 0)
                    ).to.be.equal(true)
                })
            })
            describe("main check", () => {
                it("returns false when balance insufficient", async () => {
                    const { advancedChecker, target, notOwnerAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await advancedChecker.connect(target).check(notOwnerAddress, [validEncodedNFTId], 1)
                    ).to.be.equal(false)
                })

                it("succeeds when balance sufficient", async () => {
                    const { advancedChecker, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await advancedChecker.connect(target).check(subjectAddress, [validEncodedNFTId], 1)
                    ).to.be.equal(true)
                })
            })
            describe("post check", () => {
                it("reverts when already rewarded", async () => {
                    const { rewardNft, advancedChecker, target, subjectAddress, invalidEncodedNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    await rewardNft.mint(subjectAddress)

                    expect(
                        await advancedChecker.connect(target).check(subjectAddress, [invalidEncodedNFTId], 2)
                    ).to.be.equal(false)
                })

                it("succeeds when in valid range", async () => {
                    const { advancedChecker, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await advancedChecker.connect(target).check(subjectAddress, [validEncodedNFTId], 2)
                    ).to.be.equal(true)
                })
            })
        })
    })

    describe("Policy", () => {
        async function deployAdvancedPolicyFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFT: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721CheckerFactory__factory =
                await ethers.getContractFactory("BaseERC721CheckerFactory")
            const AdvancedERC721CheckerFactory: AdvancedERC721CheckerFactory__factory =
                await ethers.getContractFactory("AdvancedERC721CheckerFactory")
            const AdvancedERC721PolicyFactory: AdvancedERC721PolicyFactory__factory =
                await ethers.getContractFactory("AdvancedERC721PolicyFactory")

            const signupNft: NFT = await NFT.deploy()
            const rewardNft: NFT = await NFT.deploy()
            const iERC721Errors: IERC721Errors = await ethers.getContractAt(
                "IERC721Errors",
                await signupNft.getAddress()
            )

            const baseCheckerFactory: BaseERC721CheckerFactory =
                await BaseERC721CheckerFactory.connect(deployer).deploy()

            const baseCheckerTx = await baseCheckerFactory.deploy(await signupNft.getAddress())
            const baseCheckerTxReceipt = await baseCheckerTx.wait()
            const baseCheckerCloneDeployedEvent = BaseERC721CheckerFactory.interface.parseLog(
                baseCheckerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const baseChecker: BaseERC721Checker = BaseERC721Checker__factory.connect(
                baseCheckerCloneDeployedEvent.args.clone,
                deployer
            )

            const advancedCheckerFactory: AdvancedERC721CheckerFactory =
                await AdvancedERC721CheckerFactory.connect(deployer).deploy()

            const advancedCheckerTx = await advancedCheckerFactory.deploy(
                await signupNft.getAddress(),
                await rewardNft.getAddress(),
                await baseChecker.getAddress(),
                1,
                0,
                10
            )
            const advancedCheckerTxReceipt = await advancedCheckerTx.wait()
            const advancedCheckerCloneDeployedEvent = AdvancedERC721CheckerFactory.interface.parseLog(
                advancedCheckerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const advancedChecker: AdvancedERC721Checker = AdvancedERC721Checker__factory.connect(
                advancedCheckerCloneDeployedEvent.args.clone,
                deployer
            )

            const advancedPolicyFactory: AdvancedERC721PolicyFactory =
                await AdvancedERC721PolicyFactory.connect(deployer).deploy()

            const advancedPolicyTx = await advancedPolicyFactory.deploy(
                await advancedChecker.getAddress(),
                false,
                false,
                true
            )
            const advancedPolicyTxReceipt = await advancedPolicyTx.wait()
            const advancedPolicyCloneDeployedEvent = AdvancedERC721PolicyFactory.interface.parseLog(
                advancedPolicyTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const advancedPolicy: AdvancedERC721Policy = AdvancedERC721Policy__factory.connect(
                advancedPolicyCloneDeployedEvent.args.clone,
                deployer
            )

            const advancedPolicSkippedTx = await advancedPolicyFactory.deploy(
                await advancedChecker.getAddress(),
                true,
                true,
                false
            )
            const advancedPolicySkippedTxReceipt = await advancedPolicSkippedTx.wait()
            const advancedPolicySkippedCloneDeployedEvent = AdvancedERC721PolicyFactory.interface.parseLog(
                advancedPolicySkippedTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const advancedPolicySkipped: AdvancedERC721Policy = AdvancedERC721Policy__factory.connect(
                advancedPolicySkippedCloneDeployedEvent.args.clone,
                deployer
            )

            // mint 0 for subject.
            await signupNft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                iERC721Errors,
                signupNft,
                rewardNft,
                baseChecker,
                advancedChecker,
                advancedPolicy,
                advancedPolicySkipped,
                deployer,
                target,
                notOwner,
                subject,
                subjectAddress,
                notOwnerAddress,
                validEncodedNFTId,
                invalidEncodedNFTId
            }
        }

        describe("initialize", () => {
            it("should deploy and initialize correctly", async () => {
                const { advancedPolicy, advancedPolicySkipped } = await loadFixture(deployAdvancedPolicyFixture)

                expect(advancedPolicy).to.not.eq(undefined)
                expect(await advancedPolicy.initialized()).to.be.eq(true)
                expect(advancedPolicySkipped).to.not.eq(undefined)
                expect(await advancedPolicySkipped.initialized()).to.be.eq(true)
            })

            it("should revert when already initialized", async () => {
                const { advancedPolicy, advancedPolicySkipped, deployer } =
                    await loadFixture(deployAdvancedPolicyFixture)

                await expect(advancedPolicy.connect(deployer).initialize()).to.be.revertedWithCustomError(
                    advancedPolicy,
                    "AlreadyInitialized"
                )
                await expect(advancedPolicySkipped.connect(deployer).initialize()).to.be.revertedWithCustomError(
                    advancedPolicySkipped,
                    "AlreadyInitialized"
                )
            })
        })

        describe("getAppendedBytes", () => {
            it("should append bytes correctly", async () => {
                const { advancedPolicy, advancedPolicySkipped, advancedChecker, deployer } =
                    await loadFixture(deployAdvancedPolicyFixture)

                const appendedBytes = await advancedPolicy.getAppendedBytes.staticCall()

                const expectedBytes = AbiCoder.defaultAbiCoder()
                    .encode(
                        ["address", "address", "bool", "bool", "bool"],
                        [await deployer.getAddress(), await advancedChecker.getAddress(), false, false, true]
                    )
                    .toLowerCase()

                expect(appendedBytes).to.equal(expectedBytes)

                const appendedBytesSkipped = await advancedPolicySkipped.getAppendedBytes.staticCall()

                const expectedBytesSkipped = AbiCoder.defaultAbiCoder()
                    .encode(
                        ["address", "address", "bool", "bool", "bool"],
                        [await deployer.getAddress(), await advancedChecker.getAddress(), true, true, false]
                    )
                    .toLowerCase()

                expect(appendedBytesSkipped).to.equal(expectedBytesSkipped)
            })
        })

        describe("trait", () => {
            it("returns correct value", async () => {
                const { advancedPolicy, advancedPolicySkipped } = await loadFixture(deployAdvancedPolicyFixture)

                expect(await advancedPolicy.trait()).to.be.eq("AdvancedERC721")
                expect(await advancedPolicySkipped.trait()).to.be.eq("AdvancedERC721")
            })
        })

        describe("setTarget", () => {
            it("reverts when caller not owner", async () => {
                const { advancedPolicy, notOwner, target } = await loadFixture(deployAdvancedPolicyFixture)

                await expect(
                    advancedPolicy.connect(notOwner).setTarget(await target.getAddress())
                ).to.be.revertedWithCustomError(advancedPolicy, "OwnableUnauthorizedAccount")
            })

            it("reverts when zero address", async () => {
                const { advancedPolicy, deployer } = await loadFixture(deployAdvancedPolicyFixture)

                await expect(advancedPolicy.connect(deployer).setTarget(ZeroAddress)).to.be.revertedWithCustomError(
                    advancedPolicy,
                    "ZeroAddress"
                )
            })

            it("sets target correctly", async () => {
                const { advancedPolicy, target } = await loadFixture(deployAdvancedPolicyFixture)
                const targetAddress = await target.getAddress()

                const tx = await advancedPolicy.setTarget(targetAddress)
                const receipt = await tx.wait()
                const event = advancedPolicy.interface.parseLog(
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
                const { advancedPolicy, target } = await loadFixture(deployAdvancedPolicyFixture)
                const targetAddress = await target.getAddress()

                await advancedPolicy.setTarget(targetAddress)

                await expect(advancedPolicy.setTarget(targetAddress)).to.be.revertedWithCustomError(
                    advancedPolicy,
                    "TargetAlreadySet"
                )
            })
        })

        describe("enforce", () => {
            describe("pre check", () => {
                it("reverts when caller not target", async () => {
                    const { advancedPolicy, subject, target, subjectAddress } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())

                    await expect(
                        advancedPolicy.connect(subject).enforce(subjectAddress, [ZeroHash], 0)
                    ).to.be.revertedWithCustomError(advancedPolicy, "TargetOnly")
                })

                it("reverts when evidence invalid", async () => {
                    const { iERC721Errors, advancedPolicy, target, subjectAddress, invalidEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())

                    await expect(
                        advancedPolicy.connect(target).enforce(subjectAddress, [invalidEncodedNFTId], 0)
                    ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
                })

                it("reverts when pre-check skipped", async () => {
                    const { advancedPolicySkipped, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicySkipped.setTarget(await target.getAddress())

                    await expect(
                        advancedPolicySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    ).to.be.revertedWithCustomError(advancedPolicySkipped, "CannotPreCheckWhenSkipped")
                })

                it("reverts when check unsuccessful", async () => {
                    const { advancedPolicy, target, notOwnerAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())

                    expect(
                        advancedPolicy.connect(target).enforce(notOwnerAddress, [validEncodedNFTId], 0)
                    ).to.be.revertedWithCustomError(advancedPolicy, "UnsuccessfulCheck")
                })

                it("enforces pre-check successfully", async () => {
                    const { advancedPolicy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await advancedPolicy.setTarget(targetAddress)

                    const tx = await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    const receipt = await tx.wait()
                    const event = advancedPolicy.interface.parseLog(
                        receipt?.logs[0] as unknown as { topics: string[]; data: string }
                    ) as unknown as {
                        args: {
                            subject: string
                            target: string
                            evidence: string
                            checkType: number
                        }
                    }

                    expect(receipt?.status).to.eq(1)
                    expect(event.args.subject).to.eq(subjectAddress)
                    expect(event.args.target).to.eq(targetAddress)
                    expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
                    expect(event.args.checkType).to.eq(0)
                    expect((await advancedPolicy.enforced(subjectAddress))[0]).to.be.equal(true)
                })

                it("reverts when pre already enforced", async () => {
                    const { advancedPolicy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())

                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)

                    await expect(
                        advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    ).to.be.revertedWithCustomError(advancedPolicy, "AlreadyEnforced")
                })
            })

            describe("main check", () => {
                it("reverts when pre-check missing", async () => {
                    const { advancedPolicy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())

                    expect(
                        advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
                    ).to.be.revertedWithCustomError(advancedPolicy, "PreCheckNotEnforced")
                })

                it("reverts when check unsuccessful", async () => {
                    const { advancedPolicy, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)

                    expect(
                        advancedPolicy.connect(target).enforce(notOwnerAddress, [validEncodedNFTId], 1)
                    ).to.be.revertedWithCustomError(advancedPolicy, "UnsuccessfulCheck")
                })

                it("enforces main-check successfully", async () => {
                    const { advancedPolicy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await advancedPolicy.setTarget(await target.getAddress())
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)

                    const tx = await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
                    const receipt = await tx.wait()
                    const event = advancedPolicy.interface.parseLog(
                        receipt?.logs[0] as unknown as { topics: string[]; data: string }
                    ) as unknown as {
                        args: {
                            subject: string
                            target: string
                            evidence: string
                            checkType: number
                        }
                    }

                    expect(receipt?.status).to.eq(1)
                    expect(event.args.subject).to.eq(subjectAddress)
                    expect(event.args.target).to.eq(targetAddress)
                    expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
                    expect(event.args.checkType).to.eq(1)
                    expect((await advancedPolicy.enforced(subjectAddress))[1]).to.be.equal(1)
                })

                it("executes multiple mains when allowed", async () => {
                    const { advancedPolicy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()
                    await advancedPolicy.setTarget(targetAddress)

                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

                    const tx = await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
                    const receipt = await tx.wait()
                    const event = advancedPolicy.interface.parseLog(
                        receipt?.logs[0] as unknown as { topics: string[]; data: string }
                    ) as unknown as {
                        args: {
                            subject: string
                            target: string
                            evidence: string
                            checkType: number
                        }
                    }

                    expect(receipt?.status).to.eq(1)
                    expect(event.args.subject).to.eq(subjectAddress)
                    expect(event.args.target).to.eq(targetAddress)
                    expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
                    expect(event.args.checkType).to.eq(1)
                    expect((await advancedPolicy.enforced(subjectAddress))[1]).to.be.equal(2)
                })

                it("reverts when main check already enfored", async () => {
                    const { advancedPolicySkipped, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicySkipped.setTarget(await target.getAddress())
                    await advancedPolicySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

                    expect(
                        advancedPolicySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
                    ).to.be.revertedWithCustomError(advancedPolicySkipped, "MainCheckAlreadyEnforced")
                })
            })

            describe("post check", () => {
                it("reverts when pre/main missing", async () => {
                    const { advancedPolicy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())

                    expect(
                        advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
                    ).to.be.revertedWithCustomError(advancedPolicy, "PreCheckNotEnforced")

                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)

                    expect(
                        advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
                    ).to.be.revertedWithCustomError(advancedPolicy, "MainCheckNotEnforced")
                })

                it("reverts when caller not target", async () => {
                    const { advancedPolicy, subject, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

                    await expect(
                        advancedPolicy.connect(subject).enforce(subjectAddress, [ZeroHash], 2)
                    ).to.be.revertedWithCustomError(advancedPolicy, "TargetOnly")
                })

                it("reverts when already rewarded", async () => {
                    const {
                        rewardNft,
                        advancedPolicy,
                        target,
                        subjectAddress,
                        validEncodedNFTId,
                        invalidEncodedNFTId
                    } = await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

                    await rewardNft.mint(subjectAddress)

                    await expect(
                        advancedPolicy.connect(target).enforce(subjectAddress, [invalidEncodedNFTId], 2)
                    ).to.be.revertedWithCustomError(advancedPolicy, "UnsuccessfulCheck")
                })

                it("reverts when post-check skipped", async () => {
                    const { advancedPolicySkipped, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicySkipped.setTarget(await target.getAddress())
                    await advancedPolicySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

                    await expect(
                        advancedPolicySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
                    ).to.be.revertedWithCustomError(advancedPolicySkipped, "CannotPostCheckWhenSkipped")
                })

                it("reverts when check unsuccessful", async () => {
                    const { advancedPolicy, target, subjectAddress, notOwnerAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

                    expect(
                        advancedPolicy.connect(target).enforce(notOwnerAddress, [validEncodedNFTId], 2)
                    ).to.be.revertedWithCustomError(advancedPolicy, "UnsuccessfulCheck")
                })

                it("enforces post-check successfully", async () => {
                    const { advancedPolicy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await advancedPolicy.setTarget(targetAddress)
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

                    const tx = await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
                    const receipt = await tx.wait()
                    const event = advancedPolicy.interface.parseLog(
                        receipt?.logs[0] as unknown as { topics: string[]; data: string }
                    ) as unknown as {
                        args: {
                            subject: string
                            target: string
                            evidence: string
                            checkType: number
                        }
                    }

                    expect(receipt?.status).to.eq(1)
                    expect(event.args.subject).to.eq(subjectAddress)
                    expect(event.args.target).to.eq(targetAddress)
                    expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
                    expect(event.args.checkType).to.eq(2)
                    expect((await advancedPolicy.enforced(subjectAddress))[2]).to.be.equal(true)
                })

                it("reverts when post already enforced", async () => {
                    const { advancedPolicy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await advancedPolicy.setTarget(await target.getAddress())
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
                    await advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)

                    await expect(
                        advancedPolicy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
                    ).to.be.revertedWithCustomError(advancedPolicy, "AlreadyEnforced")
                })
            })
        })
    })

    describe("Voting", () => {
        async function deployAdvancedVotingFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFT: NFT__factory = await ethers.getContractFactory("NFT")
            const BaseERC721CheckerFactory: BaseERC721CheckerFactory__factory =
                await ethers.getContractFactory("BaseERC721CheckerFactory")
            const AdvancedERC721CheckerFactory: AdvancedERC721CheckerFactory__factory =
                await ethers.getContractFactory("AdvancedERC721CheckerFactory")
            const AdvancedERC721PolicyFactory: AdvancedERC721PolicyFactory__factory =
                await ethers.getContractFactory("AdvancedERC721PolicyFactory")
            const AdvancedVoting: AdvancedVoting__factory = await ethers.getContractFactory("AdvancedVoting")

            const signupNft: NFT = await NFT.deploy()
            const rewardNft: NFT = await NFT.deploy()
            const iERC721Errors: IERC721Errors = await ethers.getContractAt(
                "IERC721Errors",
                await signupNft.getAddress()
            )

            const baseCheckerFactory: BaseERC721CheckerFactory =
                await BaseERC721CheckerFactory.connect(deployer).deploy()

            const baseCheckerTx = await baseCheckerFactory.deploy(await signupNft.getAddress())
            const baseCheckerTxReceipt = await baseCheckerTx.wait()
            const baseCheckerCloneDeployedEvent = BaseERC721CheckerFactory.interface.parseLog(
                baseCheckerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const baseChecker: BaseERC721Checker = BaseERC721Checker__factory.connect(
                baseCheckerCloneDeployedEvent.args.clone,
                deployer
            )

            const advancedCheckerFactory: AdvancedERC721CheckerFactory =
                await AdvancedERC721CheckerFactory.connect(deployer).deploy()

            const advancedCheckerTx = await advancedCheckerFactory.deploy(
                await signupNft.getAddress(),
                await rewardNft.getAddress(),
                await baseChecker.getAddress(),
                1,
                0,
                10
            )
            const advancedCheckerTxReceipt = await advancedCheckerTx.wait()
            const advancedCheckerCloneDeployedEvent = AdvancedERC721CheckerFactory.interface.parseLog(
                advancedCheckerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const advancedChecker: AdvancedERC721Checker = AdvancedERC721Checker__factory.connect(
                advancedCheckerCloneDeployedEvent.args.clone,
                deployer
            )

            const advancedPolicyFactory: AdvancedERC721PolicyFactory =
                await AdvancedERC721PolicyFactory.connect(deployer).deploy()

            const advancedPolicyTx = await advancedPolicyFactory.deploy(
                await advancedChecker.getAddress(),
                false,
                false,
                true
            )
            const advancedPolicyTxReceipt = await advancedPolicyTx.wait()
            const advancedPolicyCloneDeployedEvent = AdvancedERC721PolicyFactory.interface.parseLog(
                advancedPolicyTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    clone: string
                }
            }

            const advancedPolicy: AdvancedERC721Policy = AdvancedERC721Policy__factory.connect(
                advancedPolicyCloneDeployedEvent.args.clone,
                deployer
            )

            const advancedVoting: AdvancedVoting = await AdvancedVoting.connect(deployer).deploy(
                await advancedPolicy.getAddress()
            )

            // mint 0 for subject.
            await signupNft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                iERC721Errors,
                signupNft,
                rewardNft,
                baseChecker,
                advancedChecker,
                advancedPolicy,
                advancedVoting,
                deployer,
                target,
                notOwner,
                subject,
                subjectAddress,
                notOwnerAddress,
                validEncodedNFTId,
                invalidEncodedNFTId
            }
        }

        describe("constructor", () => {
            it("deploys correctly", async () => {
                const { advancedVoting } = await loadFixture(deployAdvancedVotingFixture)

                expect(advancedVoting).to.not.eq(undefined)
            })
        })

        describe("register", () => {
            it("reverts when caller not target", async () => {
                const { advancedVoting, advancedPolicy, notOwner, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await notOwner.getAddress())

                await expect(
                    advancedVoting.connect(notOwner).register(validEncodedNFTId)
                ).to.be.revertedWithCustomError(advancedPolicy, "TargetOnly")
            })

            it("reverts when evidence invalid", async () => {
                const { iERC721Errors, advancedVoting, advancedPolicy, subject, invalidEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await advancedVoting.getAddress())

                await expect(
                    advancedVoting.connect(subject).register(invalidEncodedNFTId)
                ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
            })

            it("reverts when check fails", async () => {
                const { advancedVoting, advancedPolicy, notOwner, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await advancedVoting.getAddress())

                await expect(
                    advancedVoting.connect(notOwner).register(validEncodedNFTId)
                ).to.be.revertedWithCustomError(advancedPolicy, "UnsuccessfulCheck")
            })

            it("registers successfully", async () => {
                const { advancedVoting, advancedPolicy, subject, validEncodedNFTId, subjectAddress } =
                    await loadFixture(deployAdvancedVotingFixture)
                const targetAddress = await advancedVoting.getAddress()

                await advancedPolicy.setTarget(targetAddress)

                const tx = await advancedVoting.connect(subject).register(validEncodedNFTId)
                const receipt = await tx.wait()
                const event = advancedVoting.interface.parseLog(
                    receipt?.logs[1] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect((await advancedPolicy.enforced(subjectAddress))[0]).to.be.equal(true)
                expect((await advancedPolicy.enforced(subjectAddress))[1]).to.be.equal(0n)
                expect(await advancedVoting.voteCounts(0)).to.be.equal(0)
                expect(await advancedVoting.voteCounts(1)).to.be.equal(0)
            })

            it("reverts when already registered", async () => {
                const { advancedVoting, advancedPolicy, subject, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)
                const targetAddress = await advancedVoting.getAddress()

                await advancedPolicy.setTarget(targetAddress)

                await advancedVoting.connect(subject).register(validEncodedNFTId)

                await expect(advancedVoting.connect(subject).register(validEncodedNFTId)).to.be.revertedWithCustomError(
                    advancedPolicy,
                    "AlreadyEnforced"
                )
            })
        })

        describe("vote", () => {
            it("reverts when not registered", async () => {
                const { advancedVoting, advancedPolicy, subject } = await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await advancedVoting.getAddress())

                await expect(advancedVoting.connect(subject).vote(0)).to.be.revertedWithCustomError(
                    advancedVoting,
                    "NotRegistered"
                )
            })

            it("reverts when option invalid", async () => {
                const { advancedVoting, advancedPolicy, subject, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await advancedVoting.getAddress())
                await advancedVoting.connect(subject).register(validEncodedNFTId)

                await expect(advancedVoting.connect(subject).vote(3)).to.be.revertedWithCustomError(
                    advancedVoting,
                    "InvalidOption"
                )
            })

            it("votes successfully", async () => {
                const { advancedVoting, advancedPolicy, subject, subjectAddress, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)
                const option = 0
                const targetAddress = await advancedVoting.getAddress()

                await advancedPolicy.setTarget(targetAddress)
                await advancedVoting.connect(subject).register(validEncodedNFTId)

                const tx = await advancedVoting.connect(subject).vote(option)
                const receipt = await tx.wait()
                const event = advancedVoting.interface.parseLog(
                    receipt?.logs[1] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                        option: number
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect(event.args.option).to.eq(option)
                expect((await advancedPolicy.enforced(subjectAddress))[0]).to.be.equal(true)
                expect((await advancedPolicy.enforced(subjectAddress))[1]).to.be.equal(1n)
                expect(await advancedVoting.voteCounts(0)).to.be.equal(1)
                expect(await advancedVoting.voteCounts(1)).to.be.equal(0)
            })

            it("allows multiple votes", async () => {
                const { advancedVoting, advancedPolicy, subject, subjectAddress, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)
                const option = 0
                const targetAddress = await advancedVoting.getAddress()

                await advancedPolicy.setTarget(targetAddress)
                await advancedVoting.connect(subject).register(validEncodedNFTId)
                await advancedVoting.connect(subject).vote(option)

                const tx = await advancedVoting.connect(subject).vote(option)
                const receipt = await tx.wait()
                const event = advancedVoting.interface.parseLog(
                    receipt?.logs[1] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                        option: number
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect(event.args.option).to.eq(option)
                expect((await advancedPolicy.enforced(subjectAddress))[0]).to.be.equal(true)
                expect((await advancedPolicy.enforced(subjectAddress))[1]).to.be.equal(2n)
                expect(await advancedVoting.voteCounts(0)).to.be.equal(2)
                expect(await advancedVoting.voteCounts(1)).to.be.equal(0)
            })
        })

        describe("eligibility", () => {
            it("reverts when caller not target", async () => {
                const { advancedVoting, advancedPolicy, subject, notOwner, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await notOwner.getAddress())

                await expect(advancedVoting.connect(subject).register(validEncodedNFTId)).to.be.revertedWithCustomError(
                    advancedPolicy,
                    "TargetOnly"
                )
            })

            it("reverts when already owns reward token", async () => {
                const { rewardNft, advancedVoting, advancedPolicy, subject, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await advancedVoting.getAddress())
                await advancedVoting.connect(subject).register(validEncodedNFTId)
                await advancedVoting.connect(subject).vote(0)

                await rewardNft.mint(subject)

                await expect(advancedVoting.connect(subject).eligible()).to.be.revertedWithCustomError(
                    advancedPolicy,
                    "UnsuccessfulCheck"
                )
            })

            it("reverts when check fails", async () => {
                const {
                    signupNft,
                    rewardNft,
                    deployer,
                    advancedVoting,
                    advancedPolicy,
                    notOwner,
                    subject,
                    validEncodedNFTId
                } = await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await advancedVoting.getAddress())
                await signupNft.connect(deployer).mint(notOwner)
                await advancedVoting.connect(subject).register(validEncodedNFTId)
                await advancedVoting.connect(subject).vote(0)
                await advancedVoting.connect(notOwner).register(1)
                await advancedVoting.connect(notOwner).vote(0)

                await rewardNft.connect(deployer).mint(subject)

                await expect(advancedVoting.connect(subject).eligible()).to.be.revertedWithCustomError(
                    advancedPolicy,
                    "UnsuccessfulCheck"
                )
            })

            it("reverts when not registered", async () => {
                const { advancedVoting, advancedPolicy, notOwner } = await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await notOwner.getAddress())

                await expect(advancedVoting.connect(notOwner).eligible()).to.be.revertedWithCustomError(
                    advancedVoting,
                    "NotRegistered"
                )
            })

            it("reverts when not voted", async () => {
                const { advancedVoting, advancedPolicy, subject, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await advancedVoting.getAddress())
                await advancedVoting.connect(subject).register(validEncodedNFTId)

                await expect(advancedVoting.connect(subject).eligible()).to.be.revertedWithCustomError(
                    advancedVoting,
                    "NotVoted"
                )
            })

            it("verifies eligibility successfully", async () => {
                const { advancedVoting, advancedPolicy, subject, subjectAddress, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)
                const targetAddress = await advancedVoting.getAddress()

                await advancedPolicy.setTarget(targetAddress)
                await advancedVoting.connect(subject).register(validEncodedNFTId)
                await advancedVoting.connect(subject).vote(0)

                const tx = await advancedVoting.connect(subject).eligible()
                const receipt = await tx.wait()
                const event = advancedVoting.interface.parseLog(
                    receipt?.logs[1] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect((await advancedPolicy.enforced(subjectAddress))[0]).to.be.equal(true)
                expect((await advancedPolicy.enforced(subjectAddress))[1]).to.be.equal(1n)
                expect((await advancedPolicy.enforced(subjectAddress))[2]).to.be.equal(true)
                expect(await advancedVoting.voteCounts(0)).to.be.equal(1)
                expect(await advancedVoting.voteCounts(1)).to.be.equal(0)
            })

            it("reverts when already eligible", async () => {
                const { advancedVoting, advancedPolicy, subject, validEncodedNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await advancedPolicy.setTarget(await advancedVoting.getAddress())
                await advancedVoting.connect(subject).register(validEncodedNFTId)
                await advancedVoting.connect(subject).vote(0)
                await advancedVoting.connect(subject).eligible()

                await expect(advancedVoting.connect(subject).eligible()).to.be.revertedWithCustomError(
                    advancedVoting,
                    "AlreadyEligible"
                )
            })
        })

        describe("end to end", () => {
            it("completes full voting lifecycle", async () => {
                const [deployer]: Signer[] = await ethers.getSigners()

                const NFT: NFT__factory = await ethers.getContractFactory("NFT")
                const BaseERC721CheckerFactory: BaseERC721CheckerFactory__factory =
                    await ethers.getContractFactory("BaseERC721CheckerFactory")
                const AdvancedERC721CheckerFactory: AdvancedERC721CheckerFactory__factory =
                    await ethers.getContractFactory("AdvancedERC721CheckerFactory")
                const AdvancedERC721PolicyFactory: AdvancedERC721PolicyFactory__factory =
                    await ethers.getContractFactory("AdvancedERC721PolicyFactory")
                const AdvancedVoting: AdvancedVoting__factory = await ethers.getContractFactory("AdvancedVoting")

                const signupNft: NFT = await NFT.deploy()
                const rewardNft: NFT = await NFT.deploy()

                const baseCheckerFactory: BaseERC721CheckerFactory =
                    await BaseERC721CheckerFactory.connect(deployer).deploy()

                const baseCheckerTx = await baseCheckerFactory.deploy(await signupNft.getAddress())
                const baseCheckerTxReceipt = await baseCheckerTx.wait()
                const baseCheckerCloneDeployedEvent = BaseERC721CheckerFactory.interface.parseLog(
                    baseCheckerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        clone: string
                    }
                }

                const baseChecker: BaseERC721Checker = BaseERC721Checker__factory.connect(
                    baseCheckerCloneDeployedEvent.args.clone,
                    deployer
                )

                const advancedCheckerFactory: AdvancedERC721CheckerFactory =
                    await AdvancedERC721CheckerFactory.connect(deployer).deploy()

                const advancedCheckerTx = await advancedCheckerFactory.deploy(
                    await signupNft.getAddress(),
                    await rewardNft.getAddress(),
                    await baseChecker.getAddress(),
                    1,
                    0,
                    10
                )
                const advancedCheckerTxReceipt = await advancedCheckerTx.wait()
                const advancedCheckerCloneDeployedEvent = AdvancedERC721CheckerFactory.interface.parseLog(
                    advancedCheckerTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        clone: string
                    }
                }

                const advancedChecker: AdvancedERC721Checker = AdvancedERC721Checker__factory.connect(
                    advancedCheckerCloneDeployedEvent.args.clone,
                    deployer
                )

                const advancedPolicyFactory: AdvancedERC721PolicyFactory =
                    await AdvancedERC721PolicyFactory.connect(deployer).deploy()

                const advancedPolicyTx = await advancedPolicyFactory.deploy(
                    await advancedChecker.getAddress(),
                    false,
                    false,
                    true
                )
                const advancedPolicyTxReceipt = await advancedPolicyTx.wait()
                const advancedPolicyCloneDeployedEvent = AdvancedERC721PolicyFactory.interface.parseLog(
                    advancedPolicyTxReceipt?.logs[0] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        clone: string
                    }
                }

                const advancedPolicy: AdvancedERC721Policy = AdvancedERC721Policy__factory.connect(
                    advancedPolicyCloneDeployedEvent.args.clone,
                    deployer
                )

                const advancedVoting: AdvancedVoting = await AdvancedVoting.connect(deployer).deploy(
                    await advancedPolicy.getAddress()
                )

                // set the target.
                const targetAddress = await advancedVoting.getAddress()
                await advancedPolicy.setTarget(targetAddress)

                for (const [tokenId, voter] of (await ethers.getSigners()).entries()) {
                    const voterAddress = await voter.getAddress()

                    // mint for voter.
                    await signupNft.connect(deployer).mint(voterAddress)

                    // register.
                    await advancedVoting.connect(voter).register(tokenId)

                    // vote.
                    await advancedVoting.connect(voter).vote(tokenId % 2)

                    // reward.
                    await advancedVoting.connect(voter).eligible()

                    expect((await advancedPolicy.enforced(voterAddress))[0]).to.be.equal(true)
                    expect((await advancedPolicy.enforced(voterAddress))[1]).to.be.equal(1)
                    expect((await advancedPolicy.enforced(voterAddress))[2]).to.be.equal(true)
                }
            })
        })
    })
})
