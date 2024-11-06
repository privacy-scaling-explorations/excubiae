import { expect } from "chai"
import { ethers } from "hardhat"
import { Signer, ZeroAddress, ZeroHash } from "ethers"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import {
    FreeForAllExcubia,
    FreeForAllExcubia__factory,
    FreeForAllChecker,
    FreeForAllChecker__factory
} from "../typechain-types"

describe("FreeForAllExcubia", () => {
    async function deployFreeForAllExcubiaFixture() {
        const [signer, gate, notOwner]: Signer[] = await ethers.getSigners()
        const signerAddress: string = await signer.getAddress()
        const gateAddress: string = await gate.getAddress()
        const notOwnerAddress: string = await gate.getAddress()

        const FreeForAllExcubiaContract: FreeForAllExcubia__factory =
            await ethers.getContractFactory("FreeForAllExcubia")
        const FreeForAllCheckerContract: FreeForAllChecker__factory =
            await ethers.getContractFactory("FreeForAllChecker")
        const freeForAllChecker: FreeForAllChecker = await FreeForAllCheckerContract.deploy()
        const freeForAllExcubia: FreeForAllExcubia = await FreeForAllExcubiaContract.deploy(
            await freeForAllChecker.getAddress()
        )

        // Fixtures can return anything you consider useful for your tests
        return {
            FreeForAllExcubiaContract,
            FreeForAllCheckerContract,
            freeForAllExcubia,
            freeForAllChecker,
            signer,
            gate,
            notOwner,
            signerAddress,
            gateAddress,
            notOwnerAddress
        }
    }

    describe("constructor()", () => {
        it("Should deploy the FreeForAllExcubia contract correctly", async () => {
            const { freeForAllExcubia } = await loadFixture(deployFreeForAllExcubiaFixture)

            expect(freeForAllExcubia).to.not.eq(undefined)
        })
    })

    describe("trait()", () => {
        it("should return the trait of the Excubia contract", async () => {
            const { freeForAllExcubia } = await loadFixture(deployFreeForAllExcubiaFixture)

            expect(await freeForAllExcubia.trait()).to.be.equal("FreeForAll")
        })
    })

    describe("setGate()", () => {
        it("should fail to set the gate when the caller is not the owner", async () => {
            const { freeForAllExcubia, notOwner, gateAddress } = await loadFixture(deployFreeForAllExcubiaFixture)

            await expect(freeForAllExcubia.connect(notOwner).setGate(gateAddress)).to.be.revertedWithCustomError(
                freeForAllExcubia,
                "OwnableUnauthorizedAccount"
            )
        })

        it("should fail to set the gate when the gate address is zero", async () => {
            const { freeForAllExcubia } = await loadFixture(deployFreeForAllExcubiaFixture)

            await expect(freeForAllExcubia.setGate(ZeroAddress)).to.be.revertedWithCustomError(
                freeForAllExcubia,
                "ZeroAddress"
            )
        })

        it("Should set the gate contract address correctly", async () => {
            const { FreeForAllExcubiaContract, freeForAllExcubia, gateAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            const tx = await freeForAllExcubia.setGate(gateAddress)
            const receipt = await tx.wait()
            const event = FreeForAllExcubiaContract.interface.parseLog(
                receipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    gate: string
                }
            }

            expect(receipt?.status).to.eq(1)
            expect(event.args.gate).to.eq(gateAddress)
            expect(await freeForAllExcubia.gate()).to.eq(gateAddress)
        })

        it("Should fail to set the gate if already set", async () => {
            const { freeForAllExcubia, gateAddress } = await loadFixture(deployFreeForAllExcubiaFixture)

            await freeForAllExcubia.setGate(gateAddress)

            await expect(freeForAllExcubia.setGate(gateAddress)).to.be.revertedWithCustomError(
                freeForAllExcubia,
                "GateAlreadySet"
            )
        })
    })

    describe("check()", () => {
        it("should check", async () => {
            const { freeForAllChecker, freeForAllExcubia, signerAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            // `data` parameter value can be whatever (e.g., ZeroHash default).
            await expect(freeForAllChecker.check(signerAddress, ZeroHash)).to.not.be.reverted

            // check does NOT change the state of the contract (see pass()).
            // eslint-disable-next-line @typescript-eslint/no-unused-expressions
            expect(await freeForAllExcubia.isPassed(signerAddress)).to.be.false
        })
    })

    describe("pass()", () => {
        it("should throw when the callee is not the gate", async () => {
            const { freeForAllExcubia, signer, signerAddress, gateAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            await freeForAllExcubia.setGate(gateAddress)

            await expect(
                // `data` parameter value can be whatever (e.g., ZeroHash default).
                freeForAllExcubia.connect(signer).pass(signerAddress, ZeroHash)
            ).to.be.revertedWithCustomError(freeForAllExcubia, "GateOnly")
        })

        it("should pass", async () => {
            const { FreeForAllExcubiaContract, freeForAllExcubia, gate, signerAddress, gateAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            await freeForAllExcubia.setGate(gateAddress)

            // `data` parameter value can be whatever (e.g., ZeroHash default).
            const tx = await freeForAllExcubia.connect(gate).pass(signerAddress, ZeroHash)
            const receipt = await tx.wait()
            const event = FreeForAllExcubiaContract.interface.parseLog(
                receipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    passerby: string
                    gate: string
                }
            }

            expect(receipt?.status).to.eq(1)
            expect(event.args.passerby).to.eq(signerAddress)
            expect(event.args.gate).to.eq(gateAddress)
            // eslint-disable-next-line @typescript-eslint/no-unused-expressions
            expect(await freeForAllExcubia.isPassed(signerAddress)).to.be.true
        })

        it("should prevent to pass twice", async () => {
            const { freeForAllExcubia, gate, signerAddress, gateAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            await freeForAllExcubia.setGate(gateAddress)

            await freeForAllExcubia.connect(gate).pass(signerAddress, ZeroHash)

            await expect(
                // `data` parameter value can be whatever (e.g., ZeroHash default).
                freeForAllExcubia.connect(gate).pass(signerAddress, ZeroHash)
            ).to.be.revertedWithCustomError(freeForAllExcubia, "AlreadyPassed")
        })
    })
})
