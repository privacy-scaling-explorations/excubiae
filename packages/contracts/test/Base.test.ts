import { expect } from "chai"
import { ethers } from "hardhat"
import { AbiCoder, Signer } from "ethers"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { BaseERC721Checker, BaseERC721Checker__factory, NFT, NFT__factory } from "../typechain-types"

describe("BaseChecker", () => {
    async function deployBaseCheckerFixture() {
        const [deployer, subject, target, notOwner]: Signer[] = await ethers.getSigners()
        const subjectAddress: string = await subject.getAddress()
        const notOwnerAddress: string = await notOwner.getAddress()

        const NFTFactory: NFT__factory = await ethers.getContractFactory("NFT")
        const BaseERC721CheckerFactory: BaseERC721Checker__factory =
            await ethers.getContractFactory("BaseERC721Checker")

        const nft: NFT = await NFTFactory.deploy()
        const checker: BaseERC721Checker = await BaseERC721CheckerFactory.connect(deployer).deploy(
            await nft.getAddress()
        )

        // mint 0 for subject.
        await nft.connect(deployer).mint(subjectAddress)

        // encoded token ids.
        const validNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [0])
        const invalidNFTId = AbiCoder.defaultAbiCoder().encode(["uint256"], [1])

        return {
            nft,
            checker,
            target,
            subjectAddress,
            notOwnerAddress,
            validNFTId,
            invalidNFTId
        }
    }

    describe("constructor()", () => {
        it("Should deploy the checker contract correctly", async () => {
            const { checker } = await loadFixture(deployBaseCheckerFixture)

            expect(checker).to.not.eq(undefined)
        })
    })

    describe("check()", () => {
        it("should revert the check when the evidence is not meaningful", async () => {
            const { nft, checker, target, subjectAddress, invalidNFTId } = await loadFixture(deployBaseCheckerFixture)

            await expect(checker.connect(target).check(subjectAddress, invalidNFTId)).to.be.revertedWithCustomError(
                nft,
                "ERC721NonexistentToken"
            )
        })

        it("should return false when the subject is not the owner of the evidenced token", async () => {
            const { checker, target, notOwnerAddress, validNFTId } = await loadFixture(deployBaseCheckerFixture)

            expect(await checker.connect(target).check(notOwnerAddress, validNFTId)).to.be.equal(false)
        })

        it("should check", async () => {
            const { checker, target, subjectAddress, validNFTId } = await loadFixture(deployBaseCheckerFixture)

            expect(await checker.connect(target).check(subjectAddress, validNFTId)).to.be.equal(true)
        })
    })
})
