// @todo refactoring
// describe("Advanced", () => {
//     describe("Checker", () => {
//         async function deployAdvancedCheckerFixture() {
//             const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
//             const subjectAddress: string = await subject.getAddress()
//             const notOwnerAddress: string = await notOwner.getAddress()

//             const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
//             const BaseERC721CheckerFactory: BaseERC721Checker__factory =
//                 await ethers.getContractFactory("BaseERC721Checker")
//             const AdvancedERC721CheckerFactory: AdvancedERC721Checker__factory =
//                 await ethers.getContractFactory("AdvancedERC721Checker")
//             const AdvancedERC721CheckerHarnessFactory: AdvancedERC721CheckerHarness__factory =
//                 await ethers.getContractFactory("AdvancedERC721CheckerHarness")

//             const signupNft: NFT = await NFTFactory.deploy()
//             const rewardNft: NFT = await NFTFactory.deploy()
//             const baseChecker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy([
//                 await signupNft.getAddress()
//             ])
//             const advancedChecker: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(deployer).deploy(
//                 [await signupNft.getAddress(), await rewardNft.getAddress(), await baseChecker.getAddress()],
//                 1,
//                 0,
//                 10
//             )

//             const advancedCheckerHarness: AdvancedERC721CheckerHarness =
//                 await AdvancedERC721CheckerHarnessFactory.connect(deployer).deploy(
//                     [await signupNft.getAddress(), await rewardNft.getAddress(), await baseChecker.getAddress()],
//                     1,
//                     0,
//                     10
//                 )

//             // mint 0 for subject.
//             await signupNft.connect(deployer).mint(subjectAddress)

//             // encoded token ids.
//             const validNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
//             const invalidNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

//             return {
//                 signupNft,
//                 rewardNft,
//                 baseChecker,
//                 advancedChecker,
//                 advancedCheckerHarness,
//                 deployer,
//                 target,
//                 subject,
//                 subjectAddress,
//                 notOwnerAddress,
//                 validNFTId,
//                 invalidNFTId
//             }
//         }

//         describe("constructor", () => {
//             it("deploys correctly", async () => {
//                 const { advancedChecker } = await loadFixture(deployAdvancedCheckerFixture)

//                 expect(advancedChecker).to.not.eq(undefined)
//             })
//         })

//         describe("check", () => {
//             describe("pre check", () => {
//                 it("reverts when evidence invalid", async () => {
//                     const { rewardNft, advancedChecker, target, subjectAddress, invalidNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     await expect(
//                         advancedChecker.connect(target).check(subjectAddress, [invalidNFTId], 0)
//                     ).to.be.revertedWithCustomError(rewardNft, "ERC721NonexistentToken")
//                 })

//                 it("returns false when not owner", async () => {
//                     const { advancedChecker, target, notOwnerAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(await advancedChecker.connect(target).check(notOwnerAddress, [validNFTId], 0)).to.be.equal(
//                         false
//                     )
//                 })

//                 it("succeeds when valid", async () => {
//                     const { advancedChecker, target, subjectAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(await advancedChecker.connect(target).check(subjectAddress, [validNFTId], 0)).to.be.equal(
//                         true
//                     )
//                 })
//             })
//             describe("main check", () => {
//                 it("returns false when balance insufficient", async () => {
//                     const { advancedChecker, target, notOwnerAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(await advancedChecker.connect(target).check(notOwnerAddress, [validNFTId], 1)).to.be.equal(
//                         false
//                     )
//                 })

//                 it("succeeds when balance sufficient", async () => {
//                     const { advancedChecker, target, subjectAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(await advancedChecker.connect(target).check(subjectAddress, [validNFTId], 1)).to.be.equal(
//                         true
//                     )
//                 })
//             })
//             describe("post check", () => {
//                 it("reverts when already rewarded", async () => {
//                     const { rewardNft, advancedChecker, target, subjectAddress, invalidNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     await rewardNft.mint(subjectAddress)

//                     expect(await advancedChecker.connect(target).check(subjectAddress, [invalidNFTId], 2)).to.be.equal(
//                         false
//                     )
//                 })

//                 it("succeeds when in valid range", async () => {
//                     const { advancedChecker, target, subjectAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(await advancedChecker.connect(target).check(subjectAddress, [validNFTId], 2)).to.be.equal(
//                         true
//                     )
//                 })
//             })
//         })

//         describe("getVerifierAtIndex", () => {
//             it("returns correct verifier address", async () => {
//                 const { advancedChecker, signupNft } = await loadFixture(deployAdvancedCheckerFixture)
//                 expect(await advancedChecker.getVerifierAtIndex(0)).to.equal(await signupNft.getAddress())
//             })

//             it("reverts when index out of bounds", async () => {
//                 const { advancedChecker } = await loadFixture(deployAdvancedCheckerFixture)
//                 await expect(advancedChecker.getVerifierAtIndex(5)).to.be.revertedWithCustomError(
//                     advancedChecker,
//                     "VerifierNotFound"
//                 )
//             })
//         })

//         describe("internal getVerifierAtIndex", () => {
//             it("returns correct verifier address", async () => {
//                 const { advancedCheckerHarness, signupNft } = await loadFixture(deployAdvancedCheckerFixture)
//                 expect(await advancedCheckerHarness.exposed__getVerifierAtIndex(0)).to.equal(
//                     await signupNft.getAddress()
//                 )
//             })

//             it("reverts when index out of bounds", async () => {
//                 const { advancedCheckerHarness } = await loadFixture(deployAdvancedCheckerFixture)
//                 await expect(advancedCheckerHarness.exposed__getVerifierAtIndex(5)).to.be.revertedWithCustomError(
//                     advancedCheckerHarness,
//                     "VerifierNotFound"
//                 )
//             })
//         })

//         describe("internal checks", () => {
//             describe("pre check", () => {
//                 it("reverts when evidence invalid", async () => {
//                     const { signupNft, advancedCheckerHarness, target, subjectAddress, invalidNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     await expect(
//                         advancedCheckerHarness.connect(target).exposed__check(subjectAddress, [invalidNFTId], 0)
//                     ).to.be.revertedWithCustomError(signupNft, "ERC721NonexistentToken")
//                 })

//                 it("returns false when not owner", async () => {
//                     const { advancedCheckerHarness, target, notOwnerAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(
//                         await advancedCheckerHarness.connect(target).exposed__check(notOwnerAddress, [validNFTId], 0)
//                     ).to.be.equal(false)
//                 })

//                 it("succeeds when valid", async () => {
//                     const { advancedCheckerHarness, target, subjectAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(
//                         await advancedCheckerHarness.connect(target).exposed__check(subjectAddress, [validNFTId], 0)
//                     ).to.be.equal(true)
//                 })
//             })
//             describe("main check", () => {
//                 it("returns false when balance insufficient", async () => {
//                     const { advancedCheckerHarness, target, notOwnerAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(
//                         await advancedCheckerHarness.connect(target).exposed__check(notOwnerAddress, [validNFTId], 1)
//                     ).to.be.equal(false)
//                 })

//                 it("succeeds when balance sufficient", async () => {
//                     const { advancedCheckerHarness, target, subjectAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(
//                         await advancedCheckerHarness.connect(target).exposed__check(subjectAddress, [validNFTId], 1)
//                     ).to.be.equal(true)
//                 })
//             })
//             describe("post check", () => {
//                 it("reverts when evidence invalid", async () => {
//                     const { rewardNft, advancedCheckerHarness, target, subjectAddress, invalidNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     await rewardNft.mint(subjectAddress)

//                     expect(
//                         await advancedCheckerHarness.connect(target).check(subjectAddress, [invalidNFTId], 2)
//                     ).to.be.equal(false)
//                 })

//                 it("succeeds when in valid range", async () => {
//                     const { advancedCheckerHarness, target, subjectAddress, validNFTId } =
//                         await loadFixture(deployAdvancedCheckerFixture)

//                     expect(
//                         await advancedCheckerHarness.connect(target).exposed__check(subjectAddress, [validNFTId], 2)
//                     ).to.be.equal(true)
//                 })
//             })
//         })

//         describe("internal checkPre", () => {
//             it("reverts when evidence invalid", async () => {
//                 const { signupNft, advancedCheckerHarness, target, subjectAddress, invalidNFTId } =
//                     await loadFixture(deployAdvancedCheckerFixture)

//                 await expect(
//                     advancedCheckerHarness.connect(target).exposed__checkPre(subjectAddress, [invalidNFTId])
//                 ).to.be.revertedWithCustomError(signupNft, "ERC721NonexistentToken")
//             })

//             it("returns false when not owner", async () => {
//                 const { advancedCheckerHarness, target, notOwnerAddress, validNFTId } =
//                     await loadFixture(deployAdvancedCheckerFixture)

//                 expect(
//                     await advancedCheckerHarness.connect(target).exposed__checkPre(notOwnerAddress, [validNFTId])
//                 ).to.be.equal(false)
//             })

//             it("succeeds when valid", async () => {
//                 const { advancedCheckerHarness, target, subjectAddress, validNFTId } =
//                     await loadFixture(deployAdvancedCheckerFixture)

//                 expect(
//                     await advancedCheckerHarness.connect(target).exposed__checkPre(subjectAddress, [validNFTId])
//                 ).to.be.equal(true)
//             })
//         })

//         describe("internal checkMain", () => {
//             it("returns false when balance insufficient", async () => {
//                 const { advancedCheckerHarness, target, notOwnerAddress, validNFTId } =
//                     await loadFixture(deployAdvancedCheckerFixture)

//                 expect(
//                     await advancedCheckerHarness.connect(target).exposed__checkMain(notOwnerAddress, [validNFTId])
//                 ).to.be.equal(false)
//             })

//             it("succeeds when balance sufficient", async () => {
//                 const { advancedCheckerHarness, target, subjectAddress, validNFTId } =
//                     await loadFixture(deployAdvancedCheckerFixture)

//                 expect(
//                     await advancedCheckerHarness.connect(target).exposed__checkMain(subjectAddress, [validNFTId])
//                 ).to.be.equal(true)
//             })
//         })

//         describe("internal checkPost", () => {
//             it("reverts when evidence invalid", async () => {
//                 const { rewardNft, advancedCheckerHarness, target, subjectAddress, invalidNFTId } =
//                     await loadFixture(deployAdvancedCheckerFixture)

//                 await rewardNft.mint(subjectAddress)

//                 expect(
//                     await advancedCheckerHarness.connect(target).exposed__checkPost(subjectAddress, [invalidNFTId])
//                 ).to.be.equal(false)
//             })

//             it("succeeds when in valid range", async () => {
//                 const { advancedCheckerHarness, target, subjectAddress, validNFTId } =
//                     await loadFixture(deployAdvancedCheckerFixture)

//                 expect(
//                     await advancedCheckerHarness.connect(target).exposed__checkPost(subjectAddress, [validNFTId])
//                 ).to.be.equal(true)
//             })
//         })
//     })

//     describe("Policy", () => {
//         async function deployAdvancedPolicyFixture() {
//             const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
//             const subjectAddress: string = await subject.getAddress()
//             const notOwnerAddress: string = await notOwner.getAddress()

//             const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
//             const BaseERC721CheckerFactory: BaseERC721Checker__factory =
//                 await ethers.getContractFactory("BaseERC721Checker")
//             const AdvancedERC721CheckerFactory: AdvancedERC721Checker__factory =
//                 await ethers.getContractFactory("AdvancedERC721Checker")
//             const AdvancedERC721PolicyFactory: AdvancedERC721Policy__factory =
//                 await ethers.getContractFactory("AdvancedERC721Policy")
//             const AdvancedERC721PolicyHarnessFactory: AdvancedERC721PolicyHarness__factory =
//                 await ethers.getContractFactory("AdvancedERC721PolicyHarness")

//             const signupNft: NFT = await NFTFactory.deploy()
//             const rewardNft: NFT = await NFTFactory.deploy()
//             const signupIERC721Errors: IERC721Errors = await ethers.getContractAt(
//                 "IERC721Errors",
//                 await signupNft.getAddress()
//             )
//             const rewardIERC721Errors: IERC721Errors = await ethers.getContractAt(
//                 "IERC721Errors",
//                 await rewardNft.getAddress()
//             )
//             const baseChecker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy([
//                 await signupNft.getAddress()
//             ])
//             const advancedChecker: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(deployer).deploy(
//                 [await signupNft.getAddress(), await rewardNft.getAddress(), await baseChecker.getAddress()],
//                 1,
//                 0,
//                 10
//             )

//             const advancedCheckerSkippedPrePostNoMultMain: AdvancedERC721Checker =
//                 await AdvancedERC721CheckerFactory.connect(deployer).deploy(
//                     [await signupNft.getAddress(), await rewardNft.getAddress(), await baseChecker.getAddress()],
//                     1,
//                     0,
//                     10
//                 )

//             const policy: AdvancedERC721Policy = await AdvancedERC721PolicyFactory.connect(deployer).deploy(
//                 await advancedChecker.getAddress(),
//                 false,
//                 false,
//                 true
//             )
//             const policySkipped: AdvancedERC721Policy = await AdvancedERC721PolicyFactory.connect(deployer).deploy(
//                 await advancedCheckerSkippedPrePostNoMultMain.getAddress(),
//                 true,
//                 true,
//                 false
//             )
//             const policyHarness: AdvancedERC721PolicyHarness = await AdvancedERC721PolicyHarnessFactory.connect(
//                 deployer
//             ).deploy(await advancedChecker.getAddress(), false, false, true)
//             const policyHarnessSkipped: AdvancedERC721PolicyHarness = await AdvancedERC721PolicyHarnessFactory.connect(
//                 deployer
//             ).deploy(await advancedCheckerSkippedPrePostNoMultMain.getAddress(), true, true, false)

//             // mint 0 for subject.
//             await signupNft.connect(deployer).mint(subjectAddress)

//             // encoded token ids.
//             const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
//             const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

//             return {
//                 signupIERC721Errors,
//                 rewardIERC721Errors,
//                 AdvancedERC721PolicyFactory,
//                 signupNft,
//                 rewardNft,
//                 advancedChecker,
//                 advancedCheckerSkippedPrePostNoMultMain,
//                 policyHarness,
//                 policyHarnessSkipped,
//                 policy,
//                 policySkipped,
//                 subject,
//                 deployer,
//                 target,
//                 notOwner,
//                 subjectAddress,
//                 notOwnerAddress,
//                 validEncodedNFTId,
//                 invalidEncodedNFTId
//             }
//         }

//         describe("constructor", () => {
//             it("deploys correctly", async () => {
//                 const { policy } = await loadFixture(deployAdvancedPolicyFixture)

//                 expect(policy).to.not.eq(undefined)
//             })
//         })

//         describe("trait", () => {
//             it("returns correct value", async () => {
//                 const { policy } = await loadFixture(deployAdvancedPolicyFixture)

//                 expect(await policy.trait()).to.be.eq("AdvancedERC721")
//             })
//         })

//         describe("setTarget", () => {
//             it("reverts when caller not owner", async () => {
//                 const { policy, notOwner, target } = await loadFixture(deployAdvancedPolicyFixture)

//                 await expect(
//                     policy.connect(notOwner).setTarget(await target.getAddress())
//                 ).to.be.revertedWithCustomError(policy, "OwnableUnauthorizedAccount")
//             })

//             it("reverts when zero address", async () => {
//                 const { policy, deployer } = await loadFixture(deployAdvancedPolicyFixture)

//                 await expect(policy.connect(deployer).setTarget(ZeroAddress)).to.be.revertedWithCustomError(
//                     policy,
//                     "ZeroAddress"
//                 )
//             })

//             it("sets target correctly", async () => {
//                 const { policy, target, AdvancedERC721PolicyFactory } = await loadFixture(deployAdvancedPolicyFixture)
//                 const targetAddress = await target.getAddress()

//                 const tx = await policy.setTarget(targetAddress)
//                 const receipt = await tx.wait()
//                 const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                     receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                 ) as unknown as {
//                     args: {
//                         target: string
//                     }
//                 }

//                 expect(receipt?.status).to.eq(1)
//                 expect(event.args.target).to.eq(targetAddress)
//                 expect(await policy.getTarget()).to.eq(targetAddress)
//             })

//             it("reverts when already set", async () => {
//                 const { policy, target } = await loadFixture(deployAdvancedPolicyFixture)
//                 const targetAddress = await target.getAddress()

//                 await policy.setTarget(targetAddress)

//                 await expect(policy.setTarget(targetAddress)).to.be.revertedWithCustomError(policy, "TargetAlreadySet")
//             })
//         })

//         describe("enforce", () => {
//             describe("pre check", () => {
//                 it("reverts when caller not target", async () => {
//                     const { policy, subject, target, subjectAddress } = await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())

//                     await expect(
//                         policy.connect(subject).enforce(subjectAddress, [ZeroHash], 0)
//                     ).to.be.revertedWithCustomError(policy, "TargetOnly")
//                 })

//                 it("reverts when evidence invalid", async () => {
//                     const { rewardIERC721Errors, policy, target, subjectAddress, invalidEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())

//                     await expect(
//                         policy.connect(target).enforce(subjectAddress, [invalidEncodedNFTId], 0)
//                     ).to.be.revertedWithCustomError(rewardIERC721Errors, "ERC721NonexistentToken")
//                 })

//                 it("reverts when pre-check skipped", async () => {
//                     const { policySkipped, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policySkipped.setTarget(await target.getAddress())

//                     await expect(
//                         policySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     ).to.be.revertedWithCustomError(policySkipped, "CannotPreCheckWhenSkipped")
//                 })

//                 it("reverts when check unsuccessful", async () => {
//                     const { policy, target, notOwnerAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())

//                     expect(
//                         policy.connect(target).enforce(notOwnerAddress, [validEncodedNFTId], 0)
//                     ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
//                 })

//                 it("enforces pre-check successfully", async () => {
//                     const { AdvancedERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)
//                     const targetAddress = await target.getAddress()

//                     await policy.setTarget(targetAddress)

//                     const tx = await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     const receipt = await tx.wait()
//                     const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                         receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                     ) as unknown as {
//                         args: {
//                             subject: string
//                             target: string
//                             evidence: string
//                             checkType: number
//                         }
//                     }

//                     expect(receipt?.status).to.eq(1)
//                     expect(event.args.subject).to.eq(subjectAddress)
//                     expect(event.args.target).to.eq(targetAddress)
//                     expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
//                     expect(event.args.checkType).to.eq(0)
//                     expect((await policy.enforced(subjectAddress))[0]).to.be.equal(true)
//                 })

//                 it("reverts when pre already enforced", async () => {
//                     const { policy, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())

//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)

//                     await expect(
//                         policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
//                 })
//             })

//             describe("main check", () => {
//                 it("reverts when pre-check missing", async () => {
//                     const { policy, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())

//                     expect(
//                         policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
//                     ).to.be.revertedWithCustomError(policy, "PreCheckNotEnforced")
//                 })

//                 it("reverts when check unsuccessful", async () => {
//                     const { policy, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)

//                     expect(
//                         policy.connect(target).enforce(notOwnerAddress, [validEncodedNFTId], 1)
//                     ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
//                 })

//                 it("enforces main-check successfully", async () => {
//                     const { AdvancedERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)
//                     const targetAddress = await target.getAddress()

//                     await policy.setTarget(await target.getAddress())
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)

//                     const tx = await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
//                     const receipt = await tx.wait()
//                     const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                         receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                     ) as unknown as {
//                         args: {
//                             subject: string
//                             target: string
//                             evidence: string
//                             checkType: number
//                         }
//                     }

//                     expect(receipt?.status).to.eq(1)
//                     expect(event.args.subject).to.eq(subjectAddress)
//                     expect(event.args.target).to.eq(targetAddress)
//                     expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
//                     expect(event.args.checkType).to.eq(1)
//                     expect((await policy.enforced(subjectAddress))[1]).to.be.equal(1)
//                 })

//                 it("executes multiple mains when allowed", async () => {
//                     const { AdvancedERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)
//                     const targetAddress = await target.getAddress()
//                     await policy.setTarget(targetAddress)

//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

//                     const tx = await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
//                     const receipt = await tx.wait()
//                     const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                         receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                     ) as unknown as {
//                         args: {
//                             subject: string
//                             target: string
//                             evidence: string
//                             checkType: number
//                         }
//                     }

//                     expect(receipt?.status).to.eq(1)
//                     expect(event.args.subject).to.eq(subjectAddress)
//                     expect(event.args.target).to.eq(targetAddress)
//                     expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
//                     expect(event.args.checkType).to.eq(1)
//                     expect((await policy.enforced(subjectAddress))[1]).to.be.equal(2)
//                 })

//                 it("executes multiple mains when allowed", async () => {
//                     const { policySkipped, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policySkipped.setTarget(await target.getAddress())
//                     await policySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

//                     expect(
//                         policySkipped.connect(target).enforce(notOwnerAddress, [validEncodedNFTId], 1)
//                     ).to.be.revertedWithCustomError(policySkipped, "MainCheckAlreadyEnforced")
//                 })
//             })

//             describe("post check", () => {
//                 it("reverts when pre/main missing", async () => {
//                     const { policy, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())

//                     expect(
//                         policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policy, "PreCheckNotEnforced")

//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)

//                     expect(
//                         policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policy, "MainCheckNotEnforced")
//                 })

//                 it("reverts when caller not target", async () => {
//                     const { policy, subject, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

//                     await expect(
//                         policy.connect(subject).enforce(subjectAddress, [ZeroHash], 2)
//                     ).to.be.revertedWithCustomError(policy, "TargetOnly")
//                 })

//                 it("reverts when already rewarded", async () => {
//                     const { rewardNft, policy, target, subjectAddress, validEncodedNFTId, invalidEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

//                     await rewardNft.mint(subjectAddress)

//                     await expect(
//                         policy.connect(target).enforce(subjectAddress, [invalidEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
//                 })

//                 it("reverts when post-check skipped", async () => {
//                     const { policySkipped, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policySkipped.setTarget(await target.getAddress())
//                     await policySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

//                     await expect(
//                         policySkipped.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policySkipped, "CannotPostCheckWhenSkipped")
//                 })

//                 it("reverts when check unsuccessful", async () => {
//                     const { policy, target, subjectAddress, notOwnerAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

//                     expect(
//                         policy.connect(target).enforce(notOwnerAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policy, "UnsuccessfulCheck")
//                 })

//                 it("enforces post-check successfully", async () => {
//                     const { AdvancedERC721PolicyFactory, policy, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)
//                     const targetAddress = await target.getAddress()

//                     await policy.setTarget(targetAddress)
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)

//                     const tx = await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
//                     const receipt = await tx.wait()
//                     const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                         receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                     ) as unknown as {
//                         args: {
//                             subject: string
//                             target: string
//                             evidence: string
//                             checkType: number
//                         }
//                     }

//                     expect(receipt?.status).to.eq(1)
//                     expect(event.args.subject).to.eq(subjectAddress)
//                     expect(event.args.target).to.eq(targetAddress)
//                     expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
//                     expect(event.args.checkType).to.eq(2)
//                     expect((await policy.enforced(subjectAddress))[2]).to.be.equal(true)
//                 })

//                 it("reverts when post already enforced", async () => {
//                     const { policy, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policy.setTarget(await target.getAddress())
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 1)
//                     await policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)

//                     await expect(
//                         policy.connect(target).enforce(subjectAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policy, "AlreadyEnforced")
//                 })
//             })
//         })

//         describe("internal enforce", () => {
//             describe("internal pre", () => {
//                 it("reverts when caller not target", async () => {
//                     const { policyHarness, subject, target, subjectAddress } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())

//                     await expect(
//                         policyHarness.connect(subject).exposed__enforce(subjectAddress, [ZeroHash], 0)
//                     ).to.be.revertedWithCustomError(policyHarness, "TargetOnly")
//                 })

//                 it("reverts when evidence invalid", async () => {
//                     const { rewardIERC721Errors, policyHarness, target, subjectAddress, invalidEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())

//                     await expect(
//                         policyHarness.connect(target).exposed__enforce(subjectAddress, [invalidEncodedNFTId], 0)
//                     ).to.be.revertedWithCustomError(rewardIERC721Errors, "ERC721NonexistentToken")
//                 })

//                 it("reverts when pre-check skipped", async () => {
//                     const { policyHarnessSkipped, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarnessSkipped.setTarget(await target.getAddress())

//                     await expect(
//                         policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)
//                     ).to.be.revertedWithCustomError(policyHarnessSkipped, "CannotPreCheckWhenSkipped")
//                 })

//                 it("reverts when check unsuccessful", async () => {
//                     const { policyHarness, target, notOwnerAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())

//                     expect(
//                         policyHarness.connect(target).exposed__enforce(notOwnerAddress, [validEncodedNFTId], 0)
//                     ).to.be.revertedWithCustomError(policyHarness, "UnsuccessfulCheck")
//                 })

//                 it("enforces pre-check successfully", async () => {
//                     const { AdvancedERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)
//                     const targetAddress = await target.getAddress()

//                     await policyHarness.setTarget(targetAddress)

//                     const tx = await policyHarness
//                         .connect(target)
//                         .exposed__enforce(subjectAddress, [validEncodedNFTId], 0)
//                     const receipt = await tx.wait()
//                     const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                         receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                     ) as unknown as {
//                         args: {
//                             subject: string
//                             target: string
//                             evidence: string
//                         }
//                     }

//                     expect(receipt?.status).to.eq(1)
//                     expect(event.args.subject).to.eq(subjectAddress)
//                     expect(event.args.target).to.eq(targetAddress)
//                     expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
//                     expect((await policyHarness.enforced(subjectAddress))[0]).to.be.equal(true)
//                 })

//                 it("reverts when pre already enforced", async () => {
//                     const { policyHarness, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())

//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)

//                     await expect(
//                         policyHarness.connect(target).enforce(subjectAddress, [validEncodedNFTId], 0)
//                     ).to.be.revertedWithCustomError(policyHarness, "AlreadyEnforced")
//                 })
//             })

//             describe("_main", () => {
//                 it("reverts when pre-check missing", async () => {
//                     const { policyHarness, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())

//                     expect(
//                         policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)
//                     ).to.be.revertedWithCustomError(policyHarness, "PreCheckNotEnforced")
//                 })

//                 it("reverts when check unsuccessful", async () => {
//                     const { policyHarness, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)

//                     expect(
//                         policyHarness.connect(target).exposed__enforce(notOwnerAddress, [validEncodedNFTId], 1)
//                     ).to.be.revertedWithCustomError(policyHarness, "UnsuccessfulCheck")
//                 })

//                 it("enforces main-check successfully", async () => {
//                     const { AdvancedERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)
//                     const targetAddress = await target.getAddress()

//                     await policyHarness.setTarget(await target.getAddress())
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)

//                     const tx = await policyHarness
//                         .connect(target)
//                         .exposed__enforce(subjectAddress, [validEncodedNFTId], 1)
//                     const receipt = await tx.wait()
//                     const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                         receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                     ) as unknown as {
//                         args: {
//                             subject: string
//                             target: string
//                             evidence: string
//                         }
//                     }

//                     expect(receipt?.status).to.eq(1)
//                     expect(event.args.subject).to.eq(subjectAddress)
//                     expect(event.args.target).to.eq(targetAddress)
//                     expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
//                     expect((await policyHarness.enforced(subjectAddress))[1]).to.be.equal(1)
//                 })

//                 it("executes multiple mains when allowed", async () => {
//                     const { AdvancedERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)
//                     const targetAddress = await target.getAddress()
//                     await policyHarness.setTarget(targetAddress)

//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)

//                     const tx = await policyHarness
//                         .connect(target)
//                         .exposed__enforce(subjectAddress, [validEncodedNFTId], 1)
//                     const receipt = await tx.wait()
//                     const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                         receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                     ) as unknown as {
//                         args: {
//                             subject: string
//                             target: string
//                             evidence: string
//                         }
//                     }

//                     expect(receipt?.status).to.eq(1)
//                     expect(event.args.subject).to.eq(subjectAddress)
//                     expect(event.args.target).to.eq(targetAddress)
//                     expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
//                     expect((await policyHarness.enforced(subjectAddress))[1]).to.be.equal(2)
//                 })

//                 it("executes multiple mains when allowed", async () => {
//                     const { policyHarnessSkipped, target, notOwnerAddress, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarnessSkipped.setTarget(await target.getAddress())
//                     await policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)

//                     expect(
//                         policyHarnessSkipped.connect(target).exposed__enforce(notOwnerAddress, [validEncodedNFTId], 1)
//                     ).to.be.revertedWithCustomError(policyHarnessSkipped, "MainCheckAlreadyEnforced")
//                     expect(
//                         policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)
//                     ).to.be.revertedWithCustomError(policyHarnessSkipped, "MainCheckAlreadyEnforced")
//                 })
//             })

//             describe("_post", () => {
//                 it("reverts when pre/main missing", async () => {
//                     const { policyHarness, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())

//                     expect(
//                         policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policyHarness, "PreCheckNotEnforced")

//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)

//                     expect(
//                         policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policyHarness, "MainCheckNotEnforced")
//                 })

//                 it("reverts when caller not target", async () => {
//                     const { policyHarness, subject, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)

//                     await expect(
//                         policyHarness.connect(subject).exposed__enforce(subjectAddress, [ZeroHash], 2)
//                     ).to.be.revertedWithCustomError(policyHarness, "TargetOnly")
//                 })

//                 it("reverts when evidence invalid", async () => {
//                     const { rewardNft, policyHarness, target, subjectAddress, validEncodedNFTId, invalidEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)

//                     await rewardNft.mint(subjectAddress)

//                     await expect(
//                         policyHarness.connect(target).enforce(subjectAddress, [invalidEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policyHarness, "UnsuccessfulCheck")
//                 })

//                 it("reverts when post-check skipped", async () => {
//                     const { policyHarnessSkipped, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarnessSkipped.setTarget(await target.getAddress())
//                     await policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)

//                     await expect(
//                         policyHarnessSkipped.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policyHarnessSkipped, "CannotPostCheckWhenSkipped")
//                 })

//                 it("reverts when check unsuccessful", async () => {
//                     const { policyHarness, target, subjectAddress, notOwnerAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)

//                     expect(
//                         policyHarness.connect(target).exposed__enforce(notOwnerAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policyHarness, "UnsuccessfulCheck")
//                 })

//                 it("enforces post-check successfully", async () => {
//                     const { AdvancedERC721PolicyFactory, policyHarness, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)
//                     const targetAddress = await target.getAddress()

//                     await policyHarness.setTarget(targetAddress)
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)

//                     const tx = await policyHarness
//                         .connect(target)
//                         .exposed__enforce(subjectAddress, [validEncodedNFTId], 2)
//                     const receipt = await tx.wait()
//                     const event = AdvancedERC721PolicyFactory.interface.parseLog(
//                         receipt?.logs[0] as unknown as { topics: string[]; data: string }
//                     ) as unknown as {
//                         args: {
//                             subject: string
//                             target: string
//                             evidence: string
//                         }
//                     }

//                     expect(receipt?.status).to.eq(1)
//                     expect(event.args.subject).to.eq(subjectAddress)
//                     expect(event.args.target).to.eq(targetAddress)
//                     expect(event.args.evidence[0]).to.eq(validEncodedNFTId)
//                     expect((await policyHarness.enforced(subjectAddress))[2]).to.be.equal(true)
//                 })

//                 it("reverts when post already enforced", async () => {
//                     const { policyHarness, target, subjectAddress, validEncodedNFTId } =
//                         await loadFixture(deployAdvancedPolicyFixture)

//                     await policyHarness.setTarget(await target.getAddress())
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 0)
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 1)
//                     await policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 2)

//                     await expect(
//                         policyHarness.connect(target).exposed__enforce(subjectAddress, [validEncodedNFTId], 2)
//                     ).to.be.revertedWithCustomError(policyHarness, "AlreadyEnforced")
//                 })
//             })
//         })
//     })

//     describe("Voting", () => {
//         async function deployAdvancedVotingFixture() {
//             const [deployer, subject, notOwner]: Signer[] = await ethers.getSigners()
//             const subjectAddress: string = await subject.getAddress()
//             const notOwnerAddress: string = await notOwner.getAddress()

//             const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
//             const BaseERC721CheckerFactory: BaseERC721Checker__factory =
//                 await ethers.getContractFactory("BaseERC721Checker")
//             const AdvancedERC721CheckerFactory: AdvancedERC721Checker__factory =
//                 await ethers.getContractFactory("AdvancedERC721Checker")
//             const AdvancedERC721PolicyFactory: AdvancedERC721Policy__factory =
//                 await ethers.getContractFactory("AdvancedERC721Policy")
//             const AdvancedVotingFactory: AdvancedVoting__factory = await ethers.getContractFactory("AdvancedVoting")

//             const signupNft: NFT = await NFTFactory.deploy()
//             const rewardNft: NFT = await NFTFactory.deploy()
//             const signupIERC721Errors: IERC721Errors = await ethers.getContractAt(
//                 "IERC721Errors",
//                 await signupNft.getAddress()
//             )
//             const rewardIERC721Errors: IERC721Errors = await ethers.getContractAt(
//                 "IERC721Errors",
//                 await rewardNft.getAddress()
//             )
//             const baseChecker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy([
//                 await signupNft.getAddress()
//             ])
//             const advancedChecker: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(deployer).deploy(
//                 [await signupNft.getAddress(), await rewardNft.getAddress(), await baseChecker.getAddress()],
//                 1,
//                 0,
//                 10
//             )

//             const policy: AdvancedERC721Policy = await AdvancedERC721PolicyFactory.connect(deployer).deploy(
//                 await advancedChecker.getAddress(),
//                 false,
//                 false,
//                 true
//             )

//             const voting: AdvancedVoting = await AdvancedVotingFactory.connect(deployer).deploy(
//                 await policy.getAddress()
//             )

//             // mint 0 for subject.
//             await signupNft.connect(deployer).mint(subjectAddress)

//             // encoded token ids.
//             const validNFTId = 0
//             const invalidNFTId = 1
//             const validEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [validNFTId])
//             const invalidEncodedNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [invalidNFTId])

//             return {
//                 signupIERC721Errors,
//                 rewardIERC721Errors,
//                 AdvancedVotingFactory,
//                 AdvancedERC721PolicyFactory,
//                 signupNft,
//                 rewardNft,
//                 advancedChecker,
//                 voting,
//                 policy,
//                 subject,
//                 deployer,
//                 notOwner,
//                 subjectAddress,
//                 notOwnerAddress,
//                 validNFTId,
//                 invalidNFTId,
//                 validEncodedNFTId,
//                 invalidEncodedNFTId
//             }
//         }

//         describe("constructor", () => {
//             it("deploys correctly", async () => {
//                 const { voting } = await loadFixture(deployAdvancedVotingFixture)

//                 expect(voting).to.not.eq(undefined)
//             })
//         })

//         describe("register", () => {
//             it("reverts when caller not target", async () => {
//                 const { voting, policy, notOwner, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await notOwner.getAddress())

//                 await expect(voting.connect(notOwner).register(validNFTId)).to.be.revertedWithCustomError(
//                     policy,
//                     "TargetOnly"
//                 )
//             })

//             it("reverts when evidence invalid", async () => {
//                 const { signupIERC721Errors, voting, policy, subject, invalidNFTId } =
//                     await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await voting.getAddress())

//                 await expect(voting.connect(subject).register(invalidNFTId)).to.be.revertedWithCustomError(
//                     signupIERC721Errors,
//                     "ERC721NonexistentToken"
//                 )
//             })

//             it("reverts when check fails", async () => {
//                 const { voting, policy, notOwner, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await voting.getAddress())

//                 await expect(voting.connect(notOwner).register(validNFTId)).to.be.revertedWithCustomError(
//                     policy,
//                     "UnsuccessfulCheck"
//                 )
//             })

//             it("registers successfully", async () => {
//                 const { AdvancedVotingFactory, voting, policy, subject, validNFTId, subjectAddress } =
//                     await loadFixture(deployAdvancedVotingFixture)
//                 const targetAddress = await voting.getAddress()

//                 await policy.setTarget(targetAddress)

//                 const tx = await voting.connect(subject).register(validNFTId)
//                 const receipt = await tx.wait()
//                 const event = AdvancedVotingFactory.interface.parseLog(
//                     receipt?.logs[1] as unknown as { topics: string[]; data: string }
//                 ) as unknown as {
//                     args: {
//                         voter: string
//                     }
//                 }

//                 expect(receipt?.status).to.eq(1)
//                 expect(event.args.voter).to.eq(subjectAddress)
//                 expect((await policy.enforced(subjectAddress))[0]).to.be.equal(true)
//                 expect((await policy.enforced(subjectAddress))[1]).to.be.equal(0n)
//                 expect(await voting.voteCounts(0)).to.be.equal(0)
//                 expect(await voting.voteCounts(1)).to.be.equal(0)
//             })

//             it("reverts when already registered", async () => {
//                 const { voting, policy, subject, validNFTId } = await loadFixture(deployAdvancedVotingFixture)
//                 const targetAddress = await voting.getAddress()

//                 await policy.setTarget(targetAddress)

//                 await voting.connect(subject).register(validNFTId)

//                 await expect(voting.connect(subject).register(validNFTId)).to.be.revertedWithCustomError(
//                     policy,
//                     "AlreadyEnforced"
//                 )
//             })
//         })

//         describe("vote", () => {
//             it("reverts when not registered", async () => {
//                 const { voting, policy, subject } = await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await voting.getAddress())

//                 await expect(voting.connect(subject).vote(0)).to.be.revertedWithCustomError(voting, "NotRegistered")
//             })

//             it("reverts when option invalid", async () => {
//                 const { voting, policy, subject, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await voting.getAddress())
//                 await voting.connect(subject).register(validNFTId)

//                 await expect(voting.connect(subject).vote(3)).to.be.revertedWithCustomError(voting, "InvalidOption")
//             })

//             it("votes successfully", async () => {
//                 const { AdvancedVotingFactory, voting, policy, subject, subjectAddress, validNFTId } =
//                     await loadFixture(deployAdvancedVotingFixture)
//                 const option = 0
//                 const targetAddress = await voting.getAddress()

//                 await policy.setTarget(targetAddress)
//                 await voting.connect(subject).register(validNFTId)

//                 const tx = await voting.connect(subject).vote(option)
//                 const receipt = await tx.wait()
//                 const event = AdvancedVotingFactory.interface.parseLog(
//                     receipt?.logs[1] as unknown as { topics: string[]; data: string }
//                 ) as unknown as {
//                     args: {
//                         voter: string
//                         option: number
//                     }
//                 }

//                 expect(receipt?.status).to.eq(1)
//                 expect(event.args.voter).to.eq(subjectAddress)
//                 expect(event.args.option).to.eq(option)
//                 expect((await policy.enforced(subjectAddress))[0]).to.be.equal(true)
//                 expect((await policy.enforced(subjectAddress))[1]).to.be.equal(1n)
//                 expect(await voting.voteCounts(0)).to.be.equal(1)
//                 expect(await voting.voteCounts(1)).to.be.equal(0)
//             })

//             it("allows multiple votes", async () => {
//                 const { AdvancedVotingFactory, voting, policy, subject, subjectAddress, validNFTId } =
//                     await loadFixture(deployAdvancedVotingFixture)
//                 const option = 0
//                 const targetAddress = await voting.getAddress()

//                 await policy.setTarget(targetAddress)
//                 await voting.connect(subject).register(validNFTId)
//                 await voting.connect(subject).vote(option)

//                 const tx = await voting.connect(subject).vote(option)
//                 const receipt = await tx.wait()
//                 const event = AdvancedVotingFactory.interface.parseLog(
//                     receipt?.logs[1] as unknown as { topics: string[]; data: string }
//                 ) as unknown as {
//                     args: {
//                         voter: string
//                         option: number
//                     }
//                 }

//                 expect(receipt?.status).to.eq(1)
//                 expect(event.args.voter).to.eq(subjectAddress)
//                 expect(event.args.option).to.eq(option)
//                 expect((await policy.enforced(subjectAddress))[0]).to.be.equal(true)
//                 expect((await policy.enforced(subjectAddress))[1]).to.be.equal(2n)
//                 expect(await voting.voteCounts(0)).to.be.equal(2)
//                 expect(await voting.voteCounts(1)).to.be.equal(0)
//             })
//         })

//         describe("eligibility", () => {
//             it("reverts when caller not target", async () => {
//                 const { voting, policy, subject, notOwner, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await notOwner.getAddress())

//                 await expect(voting.connect(subject).register(validNFTId)).to.be.revertedWithCustomError(
//                     policy,
//                     "TargetOnly"
//                 )
//             })

//             it("reverts when already owns reward token", async () => {
//                 const { rewardNft, voting, policy, subject, validNFTId } =
//                     await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await voting.getAddress())
//                 await voting.connect(subject).register(validNFTId)
//                 await voting.connect(subject).vote(0)

//                 await rewardNft.mint(subject)

//                 await expect(voting.connect(subject).eligible()).to.be.revertedWithCustomError(
//                     policy,
//                     "UnsuccessfulCheck"
//                 )
//             })

//             it("reverts when check fails", async () => {
//                 const { signupNft, rewardNft, deployer, voting, policy, notOwner, subject, validNFTId } =
//                     await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await voting.getAddress())
//                 await signupNft.connect(deployer).mint(notOwner)
//                 await voting.connect(subject).register(validNFTId)
//                 await voting.connect(subject).vote(0)
//                 await voting.connect(notOwner).register(1)
//                 await voting.connect(notOwner).vote(0)

//                 await rewardNft.connect(deployer).mint(subject)

//                 await expect(voting.connect(subject).eligible()).to.be.revertedWithCustomError(
//                     policy,
//                     "UnsuccessfulCheck"
//                 )
//             })

//             it("reverts when not registered", async () => {
//                 const { voting, policy, notOwner } = await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await notOwner.getAddress())

//                 await expect(voting.connect(notOwner).eligible()).to.be.revertedWithCustomError(voting, "NotRegistered")
//             })

//             it("reverts when not voted", async () => {
//                 const { voting, policy, subject, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await voting.getAddress())
//                 await voting.connect(subject).register(validNFTId)

//                 await expect(voting.connect(subject).eligible()).to.be.revertedWithCustomError(voting, "NotVoted")
//             })

//             it("verifies eligibility successfully", async () => {
//                 const { AdvancedVotingFactory, voting, policy, subject, subjectAddress, validNFTId } =
//                     await loadFixture(deployAdvancedVotingFixture)
//                 const targetAddress = await voting.getAddress()

//                 await policy.setTarget(targetAddress)
//                 await voting.connect(subject).register(validNFTId)
//                 await voting.connect(subject).vote(0)

//                 const tx = await voting.connect(subject).eligible()
//                 const receipt = await tx.wait()
//                 const event = AdvancedVotingFactory.interface.parseLog(
//                     receipt?.logs[1] as unknown as { topics: string[]; data: string }
//                 ) as unknown as {
//                     args: {
//                         voter: string
//                     }
//                 }

//                 expect(receipt?.status).to.eq(1)
//                 expect(event.args.voter).to.eq(subjectAddress)
//                 expect((await policy.enforced(subjectAddress))[0]).to.be.equal(true)
//                 expect((await policy.enforced(subjectAddress))[1]).to.be.equal(1n)
//                 expect((await policy.enforced(subjectAddress))[2]).to.be.equal(true)
//                 expect(await voting.voteCounts(0)).to.be.equal(1)
//                 expect(await voting.voteCounts(1)).to.be.equal(0)
//             })

//             it("reverts when already eligible", async () => {
//                 const { voting, policy, subject, validNFTId } = await loadFixture(deployAdvancedVotingFixture)

//                 await policy.setTarget(await voting.getAddress())
//                 await voting.connect(subject).register(validNFTId)
//                 await voting.connect(subject).vote(0)
//                 await voting.connect(subject).eligible()

//                 await expect(voting.connect(subject).eligible()).to.be.revertedWithCustomError(
//                     voting,
//                     "AlreadyEligible"
//                 )
//             })
//         })
//         describe("end to end", () => {
//             it("completes full voting lifecycle", async () => {
//                 const [deployer]: Signer[] = await ethers.getSigners()

//                 const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
//                 const BaseERC721CheckerFactory: BaseERC721Checker__factory =
//                     await ethers.getContractFactory("BaseERC721Checker")
//                 const AdvancedERC721CheckerFactory: AdvancedERC721Checker__factory =
//                     await ethers.getContractFactory("AdvancedERC721Checker")
//                 const AdvancedERC721PolicyFactory: AdvancedERC721Policy__factory =
//                     await ethers.getContractFactory("AdvancedERC721Policy")
//                 const AdvancedVotingFactory: AdvancedVoting__factory = await ethers.getContractFactory("AdvancedVoting")

//                 const signupNft: NFT = await NFTFactory.deploy()
//                 const rewardNft: NFT = await NFTFactory.deploy()
//                 const baseChecker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy([
//                     await signupNft.getAddress()
//                 ])
//                 const advancedChecker: AdvancedERC721Checker = await AdvancedERC721CheckerFactory.connect(
//                     deployer
//                 ).deploy(
//                     [await signupNft.getAddress(), await rewardNft.getAddress(), await baseChecker.getAddress()],
//                     1,
//                     0,
//                     10
//                 )

//                 const policy: AdvancedERC721Policy = await AdvancedERC721PolicyFactory.connect(deployer).deploy(
//                     await advancedChecker.getAddress(),
//                     false,
//                     false,
//                     true
//                 )

//                 const voting: AdvancedVoting = await AdvancedVotingFactory.connect(deployer).deploy(
//                     await policy.getAddress()
//                 )

//                 // set the target.
//                 const targetAddress = await voting.getAddress()
//                 await policy.setTarget(targetAddress)

//                 for (const [tokenId, voter] of (await ethers.getSigners()).entries()) {
//                     const voterAddress = await voter.getAddress()

//                     // mint for voter.
//                     await signupNft.connect(deployer).mint(voterAddress)

//                     // register.
//                     await voting.connect(voter).register(tokenId)

//                     // vote.
//                     await voting.connect(voter).vote(tokenId % 2)

//                     // reward.
//                     await voting.connect(voter).eligible()

//                     expect((await policy.enforced(voterAddress))[0]).to.be.equal(true)
//                     expect((await policy.enforced(voterAddress))[1]).to.be.equal(1)
//                     expect((await policy.enforced(voterAddress))[2]).to.be.equal(true)
//                 }
//             })
//         })
//     })
// })
