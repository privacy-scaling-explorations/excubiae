import { expect } from "chai"

import { ZeroAddress, type ContractFactory, type Signer, type TransactionReceipt } from "ethers"

import { getProxyContract, deployProxyClone, type IDeployCloneArgs, type IFactoryLike } from "../../ts"

describe("deploy", () => {
    const receipt = {
        blockNumber: 0
    } as TransactionReceipt

    const defaultArgs: IDeployCloneArgs = {
        factory: {
            connect: () => ({ attach: () => ({}) })
        } as unknown as ContractFactory,
        proxyFactory: {
            queryFilter: () => Promise.resolve([{ args: [ZeroAddress] }]),
            filters: { CloneDeployed: "CloneDeployed" },
            deploy: () => Promise.resolve({ wait: () => Promise.resolve(receipt) })
        } as unknown as IFactoryLike,
        signer: {} as Signer,
        args: []
    }

    it("should get proxy contract properly", async () => {
        const contract = await getProxyContract({ ...defaultArgs, receipt })

        expect(contract).to.not.eq(undefined)
    })

    it("should throw an error if signer is undefined", async () => {
        await expect(getProxyContract({ ...defaultArgs, receipt, signer: undefined })).to.eventually.be.rejectedWith(
            "No signer provided"
        )
    })

    it("should get proxy contract properly without receipt", async () => {
        const contract = await getProxyContract({ ...defaultArgs, receipt: undefined })

        expect(contract).to.not.eq(undefined)
    })

    it("should deploy proxy clone properly", async () => {
        const contract = await deployProxyClone(defaultArgs)

        expect(contract).to.not.eq(undefined)
    })
})
