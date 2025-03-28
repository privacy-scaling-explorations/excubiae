import type { BaseContract, ContractFactory, Signer, TransactionReceipt } from "ethers"
import type { Factory } from "../typechain-types"
import type { TypedContractMethod } from "../typechain-types/common"

/**
 * Type for the factory like contract
 */
export type IFactoryLike<P extends unknown[] = []> = Factory &
    BaseContract & {
        deploy: TypedContractMethod<P, [], "nonpayable">
    }

/**
 * Interface that represents deploy clone arguments
 */
export interface IDeployCloneArgs<T = unknown> {
    /**
     * Arguments for clone initialization
     */
    args: T[]

    /**
     * Proxied contract factory
     */
    factory: ContractFactory

    /**
     * Proxy contract factory
     */
    proxyFactory: IFactoryLike<T[]>

    /**
     * Ethereum signer
     */
    signer: Signer
}

/**
 * Interface that represents the argument for the get proxy contract function
 */
export interface IGetProxyContractArgs<F = ContractFactory> {
    /**
     * Proxied contract factory
     */
    factory: F

    /**
     * Proxy contract factory
     */
    proxyFactory: Factory

    /**
     * Ethereum signer
     */
    signer?: Signer

    /**
     * Transaction receipt
     */
    receipt?: TransactionReceipt | null
}
