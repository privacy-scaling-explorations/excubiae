import type { BaseContract } from "ethers"
import type { IDeployCloneArgs, IGetProxyContractArgs } from "./types"

/**
 * Get proxy contract from deployed proxy factory contract and receipt.
 *
 * @param args get proxy contract arguments
 * @returns proxied contract
 */
export const getProxyContract = async <T = BaseContract>({
    factory,
    proxyFactory,
    receipt,
    signer
}: IGetProxyContractArgs): Promise<T> => {
    if (!signer) {
        throw new Error("No signer provided")
    }

    const address = await proxyFactory
        .queryFilter(proxyFactory.filters.CloneDeployed, receipt?.blockNumber, receipt?.blockNumber)
        .then(([event]) => event.args[0])

    return factory.connect(signer).attach(address) as T
}

/**
 * Deploy proxy clone instance.
 *
 * @param args deploy proxy clone arguments
 * @returns clone contract
 */
export const deployProxyClone = async <C = BaseContract, T extends unknown[] = []>({
    factory,
    proxyFactory,
    signer,
    args
}: IDeployCloneArgs<T>): Promise<C> => {
    const receipt = await proxyFactory.deploy(...args).then((tx) => tx.wait())

    return getProxyContract<C>({
        factory,
        proxyFactory,
        receipt,
        signer
    })
}
