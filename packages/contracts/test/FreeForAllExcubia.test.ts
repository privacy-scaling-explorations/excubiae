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

        const FreeForAllCheckerContract: FreeForAllChecker__factory =
            await ethers.getContractFactory("FreeForAllChecker")
        const freeForAllChecker: FreeForAllChecker = await FreeForAllCheckerContract.deploy()

        const FreeForAllExcubiaContract: FreeForAllExcubia__factory =
            await ethers.getContractFactory("FreeForAllExcubia")
        const freeForAllExcubia: FreeForAllExcubia = await FreeForAllExcubiaContract.deploy(
            await freeForAllChecker.getAddress(),
            true,
            true,
            true
        )

        // Fixtures can return anything you consider useful for your tests
        return {
            FreeForAllExcubiaContract,
            freeForAllExcubia,
            FreeForAllCheckerContract,
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
            const { freeForAllExcubia, freeForAllChecker, signerAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            // `data` parameter value can be whatever (e.g., ZeroHash default).
            await expect(freeForAllChecker.checkMain(signerAddress, ZeroHash)).to.not.be.reverted

            // check does NOT change the state of the contract (see pass()).
            // eslint-disable-next-line @typescript-eslint/no-unused-expressions
            expect(await freeForAllExcubia.executionStatus(signerAddress)).to.be.eq(0)
        })
    })

    describe("pass()", () => {
        it("should throw when the callee is not the gate", async () => {
            const { freeForAllExcubia, signer, signerAddress, gateAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            await freeForAllExcubia.setGate(gateAddress)

            await expect(
                // `data` parameter value can be whatever (e.g., ZeroHash default).
                freeForAllExcubia.connect(signer).passMainCheck(signerAddress, ZeroHash)
            ).to.be.revertedWithCustomError(freeForAllExcubia, "GateOnly")
        })

        it("should pass", async () => {
            const { FreeForAllExcubiaContract, freeForAllExcubia, gate, signerAddress, gateAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            await freeForAllExcubia.setGate(gateAddress)

            // `data` parameter value can be whatever (e.g., ZeroHash default).
            const tx = await freeForAllExcubia.connect(gate).passMainCheck(signerAddress, ZeroHash)
            const receipt = await tx.wait()
            const event = FreeForAllExcubiaContract.interface.parseLog(
                receipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    passerby: string
                    data: string
                }
            }

            expect(receipt?.status).to.eq(1)
            expect(event.args.passerby).to.eq(signerAddress)
            expect(event.args.data).to.eq(ZeroHash)
            // eslint-disable-next-line @typescript-eslint/no-unused-expressions
            expect(await freeForAllExcubia.executionStatus(signerAddress)).to.be.eq(2)
        })

        it("should pass twice", async () => {
            const { FreeForAllExcubiaContract, freeForAllExcubia, gate, signerAddress, gateAddress } =
                await loadFixture(deployFreeForAllExcubiaFixture)

            await freeForAllExcubia.setGate(gateAddress)

            // 1st pass
            await freeForAllExcubia.connect(gate).passMainCheck(signerAddress, ZeroHash)

            // 2nd pass
            const tx = await freeForAllExcubia.connect(gate).passMainCheck(signerAddress, ZeroHash)
            const receipt = await tx.wait()
            const event = FreeForAllExcubiaContract.interface.parseLog(
                receipt?.logs[0] as unknown as { topics: string[]; data: string }
            ) as unknown as {
                args: {
                    passerby: string
                    data: string
                }
            }

            expect(receipt?.status).to.eq(1)
            expect(event.args.passerby).to.eq(signerAddress)
            expect(event.args.data).to.eq(ZeroHash)
            // eslint-disable-next-line @typescript-eslint/no-unused-expressions
            expect(await freeForAllExcubia.executionStatus(signerAddress)).to.be.eq(2)
        })
    })
})
