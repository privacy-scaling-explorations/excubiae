# Guides

## Writing a Clonable Checker / Policy

When implementing a policy, the first step is defining the criteria for passing validation. These criteria must be verifiable on-chain—such as token ownership, balance thresholds, or protocol-specific credentials.

For example, in a voting system where voters must own a specific NFT to participate, the validation logic resides in a **Checker** contract, while a **Policy** enforces the validation result. You can find the complete implementation in our [base test suite](https://github.com/privacy-scaling-explorations/excubiae/tree/main/packages/contracts/test/examples/base).

A checker encapsulates validation logic. The [BaseERC721Checker](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseERC721Checker.sol) is a clonable contract that verifies NFT ownership. To implement a clonable checker:

- Override `_initialize()`, which is executed only once at deployment time to store immutable arguments in the contract state.
- Implement `_check()`, defining the validation logic.

Once the checker is in place, a **Policy** references it to enforce validation. The [BaseERC721Policy](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseERC721Policy.sol) demonstrates how to:

- Extend a base policy contract.
- Provide a unique trait identifier.

To deploy clones dynamically, each Checker and Policy implementation requires a corresponding **Factory** contract. Examples include [BaseERC721CheckerFactory](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseERC721CheckerFactory.sol) and [BaseERC721PolicyFactory](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseERC721PolicyFactory.sol).

Each factory must:

1. Specify the implementation contract in the constructor and pass a new instance to the `Factory()` constructor.
2. Implement a `deploy()` method that:
    - Encodes initialization parameters (**immutable args**).
    - Calls `_deploy(data)`, deploying a clone.
    - Initializes the clone via its `initialize()` method.

This approach enables efficient deployments and customization at deploy time. For example, different `_nftAddress` values can be set per clone, allowing multiple NFT collections to use the same validation logic while remaining independent.

## Integrating a Policy

The [BaseVoting](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseVoting.sol) contract demonstrates a complete implementation of policy integration. It shows how to:

- Initialize the policy
- Enforce checks before actions
- Track validation state

### Tracking Mechanisms to Prevent Double Enforcement

Each Policy in Excubiae must implement its own tracking mechanism to prevent double enforcement. This ensures that the same proof or validation cannot be reused maliciously. The design of the tracking system may vary depending on the specific requirements of the policy.

Common Tracking Mechanisms:

Nullifier Tracking (Semaphore): Uses a mapping(uint256 => bool) to track spent nullifiers. This prevents the reuse of zero-knowledge proofs.

Address-based Tracking: Maps user addresses to a boolean to ensure a subject cannot re-enforce the same policy multiple times.

Custom Identifiers: In more complex scenarios, policies can track composite keys (e.g., mapping(bytes32 => bool)) derived from multiple validation parameters.

Example from SemaphorePolicy:

```solidity
function _enforce(address subject, bytes calldata evidence) internal override {
    ISemaphore.SemaphoreProof memory proof = abi.decode(evidence, (ISemaphore.SemaphoreProof));
    uint256 _nullifier = proof.nullifier;

    // track to avoid double spending of the same proof.
    if (spentNullifiers[_nullifier]) {
        revert AlreadyEnforced();
    }

    spentNullifiers[_nullifier] = true;

    // this takes care of unsuccessful checks (check() return false)
    // and Enforced() event emit.
    super._enforce(subject, evidence);
}
```

This pattern ensures that each proof is only used once, maintaining the integrity of the access control system.

## Wrap up

For protocol engineers and smart contract developers, Excubiae offers a powerful new approach to attribute based access control on Ethereum. Whether you're looking to implement token-gated voting, create multi-phase authentication systems, or develop novel verification mechanisms, this framework provides the tools and flexibility to bring your ideas to life.

Interested in contributing or exploring the framework further? The project welcomes collaboration through its [GitHub monorepo](https://github.com/privacy-scaling-explorations/excubiae) and [PSE Discord](https://discord.com/invite/sF5CT5rzrR) (`#ask-any-questions` channel) community. Your feedback, contributions, and innovative use cases will be crucial! Thanks for the read-through.
