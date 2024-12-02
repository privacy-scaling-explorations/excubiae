import { expect } from "chai"
import { ethers } from "hardhat"
import { AbiCoder, Signer, ZeroAddress, ZeroHash } from "ethers"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import {
    AdvancedERC721Checker,
    AdvancedERC721Checker__factory,
    AdvancedERC721CheckerHarness,
    AdvancedERC721CheckerHarness__factory,
    AdvancedERC721Policy,
    AdvancedERC721Policy__factory,
    AdvancedERC721PolicyHarness,
    AdvancedERC721PolicyHarness__factory,
    AdvancedVoting,
    AdvancedVoting__factory,
    IERC721Errors,
    NFT,
    NFT__factory
} from "../typechain-types"

describe("Advanced", () => {
    describe("Checker", () => {
        async function deployAdvancedCheckerFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
            const AdvancedERC721CheckerFactory: AdvancedERC721Checker__factory =
                await ethers.getContractFactory("AdvancedERC721Checker")
            const AdvancedERC721CheckerHarnessFactory: AdvancedERC721CheckerHarness__factory =
                await ethers.getContractFactory("AdvancedERC721CheckerHarness")

            const nft: NFT = await NFTFactory.deploy()

            const checker: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(deployer).deploy(
                await nft.getAddress(),
                1,
                0,
                10,
                false,
                false,
                true
            )

            const checkerHarness: AdvancedERC721CheckerHarness = await AdvancedERC721CheckerHarnessFactory.connect(
                deployer
            ).deploy(await nft.getAddress(), 1, 0, 10, false, false, true)

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                nft,
                checker,
                deployer,
                checkerHarness,
                target,
                subject,
                subjectAddress,
                notOwnerAddress,
                validNFTId,
                invalidNFTId
            }
        }

        describe("constructor", () => {
            it("deploys correctly", async () => {
                const { checker } = await loadFixture(deployAdvancedCheckerFixture)

                expect(checker).to.not.eq(undefined)
            })
        })

        describe("check", () => {
            describe("pre check", () => {
                it("reverts when evidence invalid", async () => {
                    const { nft, checker, target, subjectAddress, invalidNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    await expect(
                        checker.connect(target).check(subjectAddress, invalidNFTId, 0)
                    ).to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
                })

                it("returns false when not owner", async () => {
                    const { checker, target, notOwnerAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(await checker.connect(target).check(notOwnerAddress, validNFTId, 0)).to.be.equal(false)
                })

                it("succeeds when valid", async () => {
                    const { checker, target, subjectAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(await checker.connect(target).check(subjectAddress, validNFTId, 0)).to.be.equal(true)
                })
            })
            describe("main check", () => {
                it("returns false when balance insufficient", async () => {
                    const { checker, target, notOwnerAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(await checker.connect(target).check(notOwnerAddress, validNFTId, 1)).to.be.equal(false)
                })

                it("succeeds when balance sufficient", async () => {
                    const { checker, target, subjectAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(await checker.connect(target).check(subjectAddress, validNFTId, 1)).to.be.equal(true)
                })
            })
            describe("post check", () => {
                it("reverts when evidence invalid", async () => {
                    const { nft, checker, target, subjectAddress, invalidNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    await expect(
                        checker.connect(target).check(subjectAddress, invalidNFTId, 2)
                    ).to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
                })

                it("returns false when not in range", async () => {
                    const { checker, target, notOwnerAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(await checker.connect(target).check(notOwnerAddress, validNFTId, 2)).to.be.equal(false)
                })

                it("succeeds when in valid range", async () => {
                    const { checker, target, subjectAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(await checker.connect(target).check(subjectAddress, validNFTId, 2)).to.be.equal(true)
                })
            })
        })

        describe("internal checks", () => {
            describe("pre check", () => {
                it("reverts when evidence invalid", async () => {
                    const { nft, checkerHarness, target, subjectAddress, invalidNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    await expect(
                        checkerHarness.connect(target).exposed__check(subjectAddress, invalidNFTId, 0)
                    ).to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
                })

                it("returns false when not owner", async () => {
                    const { checkerHarness, target, notOwnerAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await checkerHarness.connect(target).exposed__check(notOwnerAddress, validNFTId, 0)
                    ).to.be.equal(false)
                })

                it("succeeds when valid", async () => {
                    const { checkerHarness, target, subjectAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await checkerHarness.connect(target).exposed__check(subjectAddress, validNFTId, 0)
                    ).to.be.equal(true)
                })
            })
            describe("main check", () => {
                it("returns false when balance insufficient", async () => {
                    const { checkerHarness, target, notOwnerAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await checkerHarness.connect(target).exposed__check(notOwnerAddress, validNFTId, 1)
                    ).to.be.equal(false)
                })

                it("succeeds when balance sufficient", async () => {
                    const { checkerHarness, target, subjectAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await checkerHarness.connect(target).exposed__check(subjectAddress, validNFTId, 1)
                    ).to.be.equal(true)
                })
            })
            describe("post check", () => {
                it("reverts when evidence invalid", async () => {
                    const { nft, checkerHarness, target, subjectAddress, invalidNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    await expect(
                        checkerHarness.connect(target).exposed__check(subjectAddress, invalidNFTId, 2)
                    ).to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
                })

                it("returns false when not in range", async () => {
                    const { checkerHarness, target, notOwnerAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await checkerHarness.connect(target).exposed__check(notOwnerAddress, validNFTId, 2)
                    ).to.be.equal(false)
                })

                it("succeeds when in valid range", async () => {
                    const { checkerHarness, target, subjectAddress, validNFTId } =
                        await loadFixture(deployAdvancedCheckerFixture)

                    expect(
                        await checkerHarness.connect(target).exposed__check(subjectAddress, validNFTId, 2)
                    ).to.be.equal(true)
                })
            })
        })

        describe("internal checkPre", () => {
            it("reverts when evidence invalid", async () => {
                const { nft, checkerHarness, target, subjectAddress, invalidNFTId } =
                    await loadFixture(deployAdvancedCheckerFixture)

                await expect(
                    checkerHarness.connect(target).exposed__checkPre(subjectAddress, invalidNFTId)
                ).to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
            })

            it("returns false when not owner", async () => {
                const { checkerHarness, target, notOwnerAddress, validNFTId } =
                    await loadFixture(deployAdvancedCheckerFixture)

                expect(await checkerHarness.connect(target).exposed__checkPre(notOwnerAddress, validNFTId)).to.be.equal(
                    false
                )
            })

            it("succeeds when valid", async () => {
                const { checkerHarness, target, subjectAddress, validNFTId } =
                    await loadFixture(deployAdvancedCheckerFixture)

                expect(await checkerHarness.connect(target).exposed__checkPre(subjectAddress, validNFTId)).to.be.equal(
                    true
                )
            })
        })

        describe("internal checkMain", () => {
            it("returns false when balance insufficient", async () => {
                const { checkerHarness, target, notOwnerAddress, validNFTId } =
                    await loadFixture(deployAdvancedCheckerFixture)

                expect(
                    await checkerHarness.connect(target).exposed__checkMain(notOwnerAddress, validNFTId)
                ).to.be.equal(false)
            })

            it("succeeds when balance sufficient", async () => {
                const { checkerHarness, target, subjectAddress, validNFTId } =
                    await loadFixture(deployAdvancedCheckerFixture)

                expect(await checkerHarness.connect(target).exposed__checkMain(subjectAddress, validNFTId)).to.be.equal(
                    true
                )
            })
        })

        describe("internal checkPost", () => {
            it("reverts when evidence invalid", async () => {
                const { nft, checkerHarness, target, subjectAddress, invalidNFTId } =
                    await loadFixture(deployAdvancedCheckerFixture)

                await expect(
                    checkerHarness.connect(target).exposed__checkPost(subjectAddress, invalidNFTId)
                ).to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
            })

            it("returns false when not in range", async () => {
                const { checkerHarness, target, notOwnerAddress, validNFTId } =
                    await loadFixture(deployAdvancedCheckerFixture)

                expect(
                    await checkerHarness.connect(target).exposed__checkPost(notOwnerAddress, validNFTId)
                ).to.be.equal(false)
            })

            it("succeeds when in valid range", async () => {
                const { checkerHarness, target, subjectAddress, validNFTId } =
                    await loadFixture(deployAdvancedCheckerFixture)

                expect(await checkerHarness.connect(target).exposed__checkPost(subjectAddress, validNFTId)).to.be.equal(
                    true
                )
            })
        })
    })

    describe("Policy", () => {
        async function deployAdvancedPolicyFixture() {
            const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
            const AdvancedERC721CheckerFactory: AdvancedERC721Checker__factory =
                await ethers.getContractFactory("AdvancedERC721Checker")
            const AdvancedERC721PolicyFactory: AdvancedERC721Policy__factory =
                await ethers.getContractFactory("AdvancedERC721Policy")
            const AdvancedERC721PolicyHarnessFactory: AdvancedERC721PolicyHarness__factory =
                await ethers.getContractFactory("AdvancedERC721PolicyHarness")

            const nft: NFT = await NFTFactory.deploy()
            const iERC721Errors: IERC721Errors = await ethers.getContractAt("IERC721Errors", await nft.getAddress())

            const checker: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(deployer).deploy(
                await nft.getAddress(),
                1,
                0,
                10,
                false,
                false,
                true
            )

            const checkerSkippedPrePostNoMultMain: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(
                deployer
            ).deploy(await nft.getAddress(), 1, 0, 10, true, true, false)

            const policy: AdvancedERC721Policy = await AdvancedERC721PolicyFactory.connect(deployer).deploy(
                await checker.getAddress()
            )
            const policySkipped: AdvancedERC721Policy = await AdvancedERC721PolicyFactory.connect(deployer).deploy(
                await checkerSkippedPrePostNoMultMain.getAddress()
            )
            const policyHarness: AdvancedERC721PolicyHarness = await AdvancedERC721PolicyHarnessFactory.connect(
                deployer
            ).deploy(await checker.getAddress())
            const policyHarnessSkipped: AdvancedERC721PolicyHarness = await AdvancedERC721PolicyHarnessFactory.connect(
                deployer
            ).deploy(await checkerSkippedPrePostNoMultMain.getAddress())

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

            return {
                iERC721Errors,
                AdvancedERC721PolicyFactory,
                nft,
                checker,
                policyHarness,
                policyHarnessSkipped,
                policy,
                policySkipped,
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
                const { policy } = await loadFixture(deployAdvancedPolicyFixture)

                expect(policy).to.not.eq(undefined)
            })
        })

        describe("trait", () => {
            it("returns correct value", async () => {
                const { policy } = await loadFixture(deployAdvancedPolicyFixture)

                expect(await policy.trait()).to.be.eq("AdvancedERC721")
            })
        })

        describe("setTarget", () => {
            it("reverts when caller not owner", async () => {
                const { policy, notOwner, target } = await loadFixture(deployAdvancedPolicyFixture)

                await expect(
                    policy.connect(notOwner).setTarget(await target.getAddress())
                ).to.be.revertedWithCustomError(policy, "OwnableUnauthorizedAccount")
            })

            it("reverts when zero address", async () => {
                const { policy, deployer } = await loadFixture(deployAdvancedPolicyFixture)

                await expect(policy.connect(deployer).setTarget(ZeroAddress)).to.be.revertedWithCustomError(
                    policy,
                    "ZeroAddress"
                )
            })

            it("sets target correctly", async () => {
                const { policy, target, AdvancedERC721PolicyFactory } = await loadFixture(deployAdvancedPolicyFixture)
                const targetAddress = await target.getAddress()

                const tx = await policy.setTarget(targetAddress)
                const receipt = await tx.wait()
                const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                const { policy, target } = await loadFixture(deployAdvancedPolicyFixture)
                const targetAddress = await target.getAddress()

                await policy.setTarget(targetAddress)

                await expect(policy.setTarget(targetAddress)).to.be.revertedWithCustomError(policy, "TargetAlreadySet")
            })
        })

        describe("enforce", () => {
            describe("pre check", () => {
                it("reverts when caller not target", async () => {
                    const { policy, subject, target, subjectAddress } = await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())

                    await expect(
                        policy.connect(subject).enforce(subjectAddress, ZeroHash, 0)
                    ).to.be.revertedWithCustomError(policy, "TargetOnly")
                })

                it("reverts when evidence invalid", async () => {
                    const { iERC721Errors, policy, target, subjectAddress, invalidEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())

                    await expect(
                        policy.connect(target).enforce(subjectAddress, invalidEncodedNFTId, 0)
                    ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
                })

                it("reverts when pre-check skipped", async () => {
                    const { checker, policySkipped, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policySkipped.setTarget(await target.getAddress())

                    await expect(
                        policySkipped.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    ).to.be.revertedWithCustomError(checker, "PreCheckSkipped")
                })

                it("reverts when check unsuccessful", async () => {
                    const { policy, target, notOwnerAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())

                    expect(
                        policy.connect(target).enforce(notOwnerAddress, validEncodedNFTId, 0)
                    ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
                })

                it("enforces pre-check successfully", async () => {
                    const { AdvancedERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await policy.setTarget(targetAddress)

                    const tx = await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    const receipt = await tx.wait()
                    const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                    expect(event.args.evidence).to.eq(validEncodedNFTId)
                    expect(event.args.checkType).to.eq(0)
                    expect((await policy.enforced(targetAddress, subjectAddress))[0]).to.be.equal(true)
                })

                it("reverts when pre already enforced", async () => {
                    const { policy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())

                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)

                    await expect(
                        policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
                })
            })

            describe("main check", () => {
                it("reverts when pre-check missing", async () => {
                    const { policy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())

                    expect(
                        policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)
                    ).to.be.revertedWithCustomError(policy, "PreCheckNotEnforced")
                })

                it("reverts when check unsuccessful", async () => {
                    const { policy, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)

                    expect(
                        policy.connect(target).enforce(notOwnerAddress, validEncodedNFTId, 1)
                    ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
                })

                it("enforces main-check successfully", async () => {
                    const { AdvancedERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await policy.setTarget(await target.getAddress())
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)

                    const tx = await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)
                    const receipt = await tx.wait()
                    const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                    expect(event.args.evidence).to.eq(validEncodedNFTId)
                    expect(event.args.checkType).to.eq(1)
                    expect((await policy.enforced(targetAddress, subjectAddress))[1]).to.be.equal(1)
                })

                it("executes multiple mains when allowed", async () => {
                    const { AdvancedERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()
                    await policy.setTarget(targetAddress)

                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)

                    const tx = await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)
                    const receipt = await tx.wait()
                    const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                    expect(event.args.evidence).to.eq(validEncodedNFTId)
                    expect(event.args.checkType).to.eq(1)
                    expect((await policy.enforced(targetAddress, subjectAddress))[1]).to.be.equal(2)
                })

                it("executes multiple mains when allowed", async () => {
                    const { policySkipped, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policySkipped.setTarget(await target.getAddress())
                    await policySkipped.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)

                    expect(
                        policySkipped.connect(target).enforce(notOwnerAddress, validEncodedNFTId, 1)
                    ).to.be.revertedWithCustomError(policySkipped, "MainCheckAlreadyEnforced")
                })
            })

            describe("post check", () => {
                it("reverts when pre/main missing", async () => {
                    const { policy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())

                    expect(
                        policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(policy, "PreCheckNotEnforced")

                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)

                    expect(
                        policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(policy, "MainCheckNotEnforced")
                })

                it("reverts when caller not target", async () => {
                    const { policy, subject, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)

                    await expect(
                        policy.connect(subject).enforce(subjectAddress, ZeroHash, 2)
                    ).to.be.revertedWithCustomError(policy, "TargetOnly")
                })

                it("reverts when evidence invalid", async () => {
                    const { iERC721Errors, policy, target, subjectAddress, validEncodedNFTId, invalidEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)

                    await expect(
                        policy.connect(target).enforce(subjectAddress, invalidEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
                })

                it("reverts when post-check skipped", async () => {
                    const { checker, policySkipped, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policySkipped.setTarget(await target.getAddress())
                    await policySkipped.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)

                    await expect(
                        policySkipped.connect(target).enforce(subjectAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(checker, "PostCheckSkipped")
                })

                it("reverts when check unsuccessful", async () => {
                    const { policy, target, subjectAddress, notOwnerAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)

                    expect(
                        policy.connect(target).enforce(notOwnerAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
                })

                it("enforces post-check successfully", async () => {
                    const { AdvancedERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await policy.setTarget(targetAddress)
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)

                    const tx = await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 2)
                    const receipt = await tx.wait()
                    const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                    expect(event.args.evidence).to.eq(validEncodedNFTId)
                    expect(event.args.checkType).to.eq(2)
                    expect((await policy.enforced(targetAddress, subjectAddress))[2]).to.be.equal(true)
                })

                it("reverts when post already enforced", async () => {
                    const { policy, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policy.setTarget(await target.getAddress())
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 1)
                    await policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 2)

                    await expect(
                        policy.connect(target).enforce(subjectAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
                })
            })
        })

        describe("internal enforce", () => {
            describe("internal pre", () => {
                it("reverts when caller not target", async () => {
                    const { policyHarness, subject, target, subjectAddress } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())

                    await expect(
                        policyHarness.connect(subject).exposed__enforce(subjectAddress, ZeroHash, 0)
                    ).to.be.revertedWithCustomError(policyHarness, "TargetOnly")
                })

                it("reverts when evidence invalid", async () => {
                    const { iERC721Errors, policyHarness, target, subjectAddress, invalidEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())

                    await expect(
                        policyHarness.connect(target).exposed__enforce(subjectAddress, invalidEncodedNFTId, 0)
                    ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
                })

                it("reverts when pre-check skipped", async () => {
                    const { checker, policyHarnessSkipped, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarnessSkipped.setTarget(await target.getAddress())

                    await expect(
                        policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)
                    ).to.be.revertedWithCustomError(checker, "PreCheckSkipped")
                })

                it("reverts when check unsuccessful", async () => {
                    const { policyHarness, target, notOwnerAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())

                    expect(
                        policyHarness.connect(target).exposed__enforce(notOwnerAddress, validEncodedNFTId, 0)
                    ).to.be.revertedWithCustomError(policyHarness, "UnsuccessfulCheck")
                })

                it("enforces pre-check successfully", async () => {
                    const { AdvancedERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await policyHarness.setTarget(targetAddress)

                    const tx = await policyHarness
                        .connect(target)
                        .exposed__enforce(subjectAddress, validEncodedNFTId, 0)
                    const receipt = await tx.wait()
                    const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                    expect((await policyHarness.enforced(targetAddress, subjectAddress))[0]).to.be.equal(true)
                })

                it("reverts when pre already enforced", async () => {
                    const { policyHarness, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())

                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)

                    await expect(
                        policyHarness.connect(target).enforce(subjectAddress, validEncodedNFTId, 0)
                    ).to.be.revertedWithCustomError(policyHarness, "AlreadyEnforced")
                })
            })

            describe("_main", () => {
                it("reverts when pre-check missing", async () => {
                    const { policyHarness, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())

                    expect(
                        policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)
                    ).to.be.revertedWithCustomError(policyHarness, "PreCheckNotEnforced")
                })

                it("reverts when check unsuccessful", async () => {
                    const { policyHarness, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)

                    expect(
                        policyHarness.connect(target).exposed__enforce(notOwnerAddress, validEncodedNFTId, 1)
                    ).to.be.revertedWithCustomError(policyHarness, "UnsuccessfulCheck")
                })

                it("enforces main-check successfully", async () => {
                    const { AdvancedERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await policyHarness.setTarget(await target.getAddress())
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)

                    const tx = await policyHarness
                        .connect(target)
                        .exposed__enforce(subjectAddress, validEncodedNFTId, 1)
                    const receipt = await tx.wait()
                    const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                    expect((await policyHarness.enforced(targetAddress, subjectAddress))[1]).to.be.equal(1)
                })

                it("executes multiple mains when allowed", async () => {
                    const { AdvancedERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()
                    await policyHarness.setTarget(targetAddress)

                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)

                    const tx = await policyHarness
                        .connect(target)
                        .exposed__enforce(subjectAddress, validEncodedNFTId, 1)
                    const receipt = await tx.wait()
                    const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                    expect((await policyHarness.enforced(targetAddress, subjectAddress))[1]).to.be.equal(2)
                })

                it("executes multiple mains when allowed", async () => {
                    const { policyHarnessSkipped, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarnessSkipped.setTarget(await target.getAddress())
                    await policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)

                    expect(
                        policyHarnessSkipped.connect(target).exposed__enforce(notOwnerAddress, validEncodedNFTId, 1)
                    ).to.be.revertedWithCustomError(policyHarnessSkipped, "MainCheckAlreadyEnforced")
                    expect(
                        policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)
                    ).to.be.revertedWithCustomError(policyHarnessSkipped, "MainCheckAlreadyEnforced")
                })
            })

            describe("_post", () => {
                it("reverts when pre/main missing", async () => {
                    const { policyHarness, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())

                    expect(
                        policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(policyHarness, "PreCheckNotEnforced")

                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)

                    expect(
                        policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(policyHarness, "MainCheckNotEnforced")
                })

                it("reverts when caller not target", async () => {
                    const { policyHarness, subject, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)

                    await expect(
                        policyHarness.connect(subject).exposed__enforce(subjectAddress, ZeroHash, 2)
                    ).to.be.revertedWithCustomError(policyHarness, "TargetOnly")
                })

                it("reverts when evidence invalid", async () => {
                    const {
                        iERC721Errors,
                        policyHarness,
                        target,
                        subjectAddress,
                        validEncodedNFTId,
                        invalidEncodedNFTId
                    } = await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)

                    await expect(
                        policyHarness.connect(target).exposed__enforce(subjectAddress, invalidEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(iERC721Errors, "ERC721NonexistentToken")
                })

                it("reverts when post-check skipped", async () => {
                    const { checker, policyHarnessSkipped, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarnessSkipped.setTarget(await target.getAddress())
                    await policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)

                    await expect(
                        policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(checker, "PostCheckSkipped")
                })

                it("reverts when check unsuccessful", async () => {
                    const { policyHarness, target, subjectAddress, notOwnerAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)

                    expect(
                        policyHarness.connect(target).exposed__enforce(notOwnerAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(policyHarness, "UnsuccessfulCheck")
                })

                it("enforces post-check successfully", async () => {
                    const { AdvancedERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)
                    const targetAddress = await target.getAddress()

                    await policyHarness.setTarget(targetAddress)
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)

                    const tx = await policyHarness
                        .connect(target)
                        .exposed__enforce(subjectAddress, validEncodedNFTId, 2)
                    const receipt = await tx.wait()
                    const event = AdvancedERC721PolicyFactory.interface.parseLog(
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
                    expect((await policyHarness.enforced(targetAddress, subjectAddress))[2]).to.be.equal(true)
                })

                it("reverts when post already enforced", async () => {
                    const { policyHarness, target, subjectAddress, validEncodedNFTId } =
                        await loadFixture(deployAdvancedPolicyFixture)

                    await policyHarness.setTarget(await target.getAddress())
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 0)
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 1)
                    await policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 2)

                    await expect(
                        policyHarness.connect(target).exposed__enforce(subjectAddress, validEncodedNFTId, 2)
                    ).to.be.revertedWithCustomError(policyHarness, "AlreadyEnforced")
                })
            })
        })
    })

    describe("Voting", () => {
        async function deployAdvancedVotingFixture() {
            const [deployer, subject, notOwner]: Signer[] = await ethers.getSigners()
            const subjectAddress: string = await subject.getAddress()
            const notOwnerAddress: string = await notOwner.getAddress()

            const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
            const AdvancedERC721CheckerFactory: AdvancedERC721Checker__factory =
                await ethers.getContractFactory("AdvancedERC721Checker")
            const AdvancedERC721PolicyFactory: AdvancedERC721Policy__factory =
                await ethers.getContractFactory("AdvancedERC721Policy")
            const AdvancedVotingFactory: AdvancedVoting__factory = await ethers.getContractFactory("AdvancedVoting")

            const nft: NFT = await NFTFactory.deploy()
            const iERC721Errors: IERC721Errors = await ethers.getContractAt("IERC721Errors", await nft.getAddress())

            const checker: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(deployer).deploy(
                await nft.getAddress(),
                1,
                0,
                10,
                false,
                false,
                true
            )

            const policy: AdvancedERC721Policy = await AdvancedERC721PolicyFactory.connect(deployer).deploy(
                await checker.getAddress()
            )

            const voting: AdvancedVoting = await AdvancedVotingFactory.connect(deployer).deploy(
                await policy.getAddress()
            )

            // mint 0 for subject.
            await nft.connect(deployer).mint(subjectAddress)

            // encoded token ids.
            const validNFTId = 0
            const invalidNFTId = 1
            const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [validNFTId])
            const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [invalidNFTId])

            return {
                iERC721Errors,
                AdvancedVotingFactory,
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
                const { voting } = await loadFixture(deployAdvancedVotingFixture)

                expect(voting).to.not.eq(undefined)
            })
        })

        describe("register", () => {
            it("reverts when caller not target", async () => {
                const { voting, policy, notOwner, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await notOwner.getAddress())

                await expect(voting.connect(notOwner).register(validNFTId)).to.be.revertedWithCustomError(
                    policy,
                    "TargetOnly"
                )
            })

            it("reverts when evidence invalid", async () => {
                const { iERC721Errors, voting, policy, subject, invalidNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await voting.getAddress())

                await expect(voting.connect(subject).register(invalidNFTId)).to.be.revertedWithCustomError(
                    iERC721Errors,
                    "ERC721NonexistentToken"
                )
            })

            it("reverts when check fails", async () => {
                const { voting, policy, notOwner, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await voting.getAddress())

                await expect(voting.connect(notOwner).register(validNFTId)).to.be.revertedWithCustomError(
                    policy,
                    "UnsuccessfulCheck"
                )
            })

            it("registers successfully", async () => {
                const { AdvancedVotingFactory, voting, policy, subject, validNFTId, subjectAddress } =
                    await loadFixture(deployAdvancedVotingFixture)
                const targetAddress = await voting.getAddress()

                await policy.setTarget(targetAddress)

                const tx = await voting.connect(subject).register(validNFTId)
                const receipt = await tx.wait()
                const event = AdvancedVotingFactory.interface.parseLog(
                    receipt?.logs[1] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect((await policy.enforced(targetAddress, subjectAddress))[0]).to.be.equal(true)
                expect((await policy.enforced(targetAddress, subjectAddress))[1]).to.be.equal(0n)
                expect(await voting.voteCounts(0)).to.be.equal(0)
                expect(await voting.voteCounts(1)).to.be.equal(0)
            })

            it("reverts when already registered", async () => {
                const { voting, policy, subject, validNFTId } = await loadFixture(deployAdvancedVotingFixture)
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
                const { voting, policy, subject } = await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await voting.getAddress())

                await expect(voting.connect(subject).vote(0)).to.be.revertedWithCustomError(voting, "NotRegistered")
            })

            it("reverts when option invalid", async () => {
                const { voting, policy, subject, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await voting.getAddress())
                await voting.connect(subject).register(validNFTId)

                await expect(voting.connect(subject).vote(3)).to.be.revertedWithCustomError(voting, "InvalidOption")
            })

            it("votes successfully", async () => {
                const { AdvancedVotingFactory, voting, policy, subject, subjectAddress, validNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)
                const option = 0
                const targetAddress = await voting.getAddress()

                await policy.setTarget(targetAddress)
                await voting.connect(subject).register(validNFTId)

                const tx = await voting.connect(subject).vote(option)
                const receipt = await tx.wait()
                const event = AdvancedVotingFactory.interface.parseLog(
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
                expect((await policy.enforced(targetAddress, subjectAddress))[0]).to.be.equal(true)
                expect((await policy.enforced(targetAddress, subjectAddress))[1]).to.be.equal(1n)
                expect(await voting.voteCounts(0)).to.be.equal(1)
                expect(await voting.voteCounts(1)).to.be.equal(0)
            })

            it("allows multiple votes", async () => {
                const { AdvancedVotingFactory, voting, policy, subject, subjectAddress, validNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)
                const option = 0
                const targetAddress = await voting.getAddress()

                await policy.setTarget(targetAddress)
                await voting.connect(subject).register(validNFTId)
                await voting.connect(subject).vote(option)

                const tx = await voting.connect(subject).vote(option)
                const receipt = await tx.wait()
                const event = AdvancedVotingFactory.interface.parseLog(
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
                expect((await policy.enforced(targetAddress, subjectAddress))[0]).to.be.equal(true)
                expect((await policy.enforced(targetAddress, subjectAddress))[1]).to.be.equal(2n)
                expect(await voting.voteCounts(0)).to.be.equal(2)
                expect(await voting.voteCounts(1)).to.be.equal(0)
            })
        })

        describe("reward", () => {
            it("reverts when caller not target", async () => {
                const { voting, policy, subject, notOwner, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await notOwner.getAddress())

                await expect(voting.connect(subject).register(validNFTId)).to.be.revertedWithCustomError(
                    policy,
                    "TargetOnly"
                )
            })

            it("reverts when evidence invalid", async () => {
                const { iERC721Errors, voting, policy, subject, validNFTId, invalidNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await voting.getAddress())
                await voting.connect(subject).register(validNFTId)
                await voting.connect(subject).vote(0)

                await expect(voting.connect(subject).reward(invalidNFTId)).to.be.revertedWithCustomError(
                    iERC721Errors,
                    "ERC721NonexistentToken"
                )
            })

            it("reverts when check fails", async () => {
                const { nft, deployer, voting, policy, notOwner, subject, validNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await voting.getAddress())
                await nft.connect(deployer).mint(notOwner)
                await voting.connect(subject).register(validNFTId)
                await voting.connect(subject).vote(0)
                await voting.connect(notOwner).register(1)
                await voting.connect(notOwner).vote(0)

                await expect(voting.connect(subject).reward(1)).to.be.revertedWithCustomError(
                    policy,
                    "UnsuccessfulCheck"
                )
            })

            it("reverts when not registered", async () => {
                const { voting, policy, notOwner, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await notOwner.getAddress())

                await expect(voting.connect(notOwner).reward(validNFTId)).to.be.revertedWithCustomError(
                    voting,
                    "NotRegistered"
                )
            })

            it("reverts when not voted", async () => {
                const { voting, policy, subject, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await voting.getAddress())
                await voting.connect(subject).register(validNFTId)

                await expect(voting.connect(subject).reward(validNFTId)).to.be.revertedWithCustomError(
                    voting,
                    "NotVoted"
                )
            })

            it("claims reward successfully", async () => {
                const { AdvancedVotingFactory, voting, policy, subject, subjectAddress, validNFTId } =
                    await loadFixture(deployAdvancedVotingFixture)
                const targetAddress = await voting.getAddress()

                await policy.setTarget(targetAddress)
                await voting.connect(subject).register(validNFTId)
                await voting.connect(subject).vote(0)

                const tx = await voting.connect(subject).reward(validNFTId)
                const receipt = await tx.wait()
                const event = AdvancedVotingFactory.interface.parseLog(
                    receipt?.logs[1] as unknown as { topics: string[]; data: string }
                ) as unknown as {
                    args: {
                        voter: string
                    }
                }

                expect(receipt?.status).to.eq(1)
                expect(event.args.voter).to.eq(subjectAddress)
                expect((await policy.enforced(targetAddress, subjectAddress))[0]).to.be.equal(true)
                expect((await policy.enforced(targetAddress, subjectAddress))[1]).to.be.equal(1n)
                expect((await policy.enforced(targetAddress, subjectAddress))[2]).to.be.equal(true)
                expect(await voting.voteCounts(0)).to.be.equal(1)
                expect(await voting.voteCounts(1)).to.be.equal(0)
            })

            it("reverts when already claimed", async () => {
                const { voting, policy, subject, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

                await policy.setTarget(await voting.getAddress())
                await voting.connect(subject).register(validNFTId)
                await voting.connect(subject).vote(0)
                await voting.connect(subject).reward(validNFTId)

                await expect(voting.connect(subject).reward(validNFTId)).to.be.revertedWithCustomError(
                    voting,
                    "AlreadyClaimed"
                )
            })
        })
        describe("end to end", () => {
            it("completes full voting lifecycle", async () => {
                const [deployer]: Signer[] = await ethers.getSigners()

                const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
                const AdvancedERC721CheckerFactory: AdvancedERC721Checker__factory =
                    await ethers.getContractFactory("AdvancedERC721Checker")
                const AdvancedERC721PolicyFactory: AdvancedERC721Policy__factory =
                    await ethers.getContractFactory("AdvancedERC721Policy")
                const AdvancedVotingFactory: AdvancedVoting__factory = await ethers.getContractFactory("AdvancedVoting")

                const nft: NFT = await NFTFactory.deploy()

                const checker: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(deployer).deploy(
                    await nft.getAddress(),
                    1,
                    0,
                    20,
                    false,
                    false,
                    true
                )

                const policy: AdvancedERC721Policy = await AdvancedERC721PolicyFactory.connect(deployer).deploy(
                    await checker.getAddress()
                )

                const voting: AdvancedVoting = await AdvancedVotingFactory.connect(deployer).deploy(
                    await policy.getAddress()
                )

                // set the target.
                const targetAddress = await voting.getAddress()
                await policy.setTarget(targetAddress)

                for (const [tokenId, voter] of (await ethers.getSigners()).entries()) {
                    const voterAddress = await voter.getAddress()

                    // mint for voter.
                    await nft.connect(deployer).mint(voterAddress)

                    // register.
                    await voting.connect(voter).register(tokenId)

                    // vote.
                    await voting.connect(voter).vote(tokenId % 2)

                    // reward.
                    await voting.connect(voter).reward(tokenId)

                    expect((await policy.enforced(targetAddress, voterAddress))[0]).to.be.equal(true)
                    expect((await policy.enforced(targetAddress, voterAddress))[1]).to.be.equal(1)
                    expect((await policy.enforced(targetAddress, voterAddress))[2]).to.be.equal(true)
                }
            })
        })
    })
})
