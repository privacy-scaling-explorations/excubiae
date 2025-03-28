# Use Cases

## Basic Access Control for Voting

Access control in voting systems presents a common challenge in smart contract development. For example, when implementing restrictions to check voters identity, developers often face the decision of where to place validation logic. Traditional approaches tend to embed these checks directly within voting contracts, leading to tightly coupled systems that prove difficult to maintain or adapt.

Excubiae addresses this challenge through its fundamental principle of separation between voting logic and access control. The framework enables a clean architecture where voting contracts remain focused on their core purpose while delegating all validation to specialized components.

Consider this implementation using Excubiae's base components to check voters identity through the possession of an NFT (see [BaseVoting](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseVoting.sol) example).

```solidity
contract BaseVoting {
    BasePolicy public immutable POLICY;
    mapping(address => bool) public hasVoted;
    mapping(uint8 => uint256) public voteCounts;

    constructor(BaseERC721Policy _policy) {
        POLICY = _policy;
    }

    function register(uint256 tokenId) external {
        bytes[] memory _evidence = new bytes[](1);
        _evidence[0] = abi.encode(tokenId);

        POLICY.enforce(msg.sender, _evidence);

        emit Registered(msg.sender);
    }

    function vote(uint8 option) external {
        if (!POLICY.enforced(msg.sender)) revert NotRegistered();
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        if (option >= 2) revert InvalidOption();

        hasVoted[msg.sender] = true;
        voteCounts[option]++;

        emit Voted(msg.sender, option);
    }
}
```

The validation logic resides in its own set of specialized contracts (see [BaseERC721Policy](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseERC721Policy.sol) and [BaseERC721Checker](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseERC721Checker.sol) examples) along with the respective Factory contracts (see [BaseERC721PolicyFactory](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseERC721PolicyFactory.sol) and [BaseERC721CheckerFactory](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/base/BaseERC721CheckerFactory.sol) examples)

This architecture demonstrates the core strengths of Excubiae's design. The voting contract maintains singular responsibility for vote management, while the policy and checker contracts handle all aspects of access control. This separation enables easy modification of validation rules without affecting the voting logic itself. Indeed, through minimal proxy pattern, anyone is able to deploy, for example, a new Checker with a different NFT address as reference for the checks and a new Policy referencing to another Checker.

You can explore complete implementations, including comprehensive test cases ([Solidity](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/Base.t.sol) & [Typescript](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/Base.test.ts)) on the monorepo. These examples provide practical insights into integration patterns and usage scenarios.

The framework's capabilities extend beyond this basic implementation. For scenarios requiring multi-step validation or combined verification rules, Excubiae provides advanced components that we'll explore next.

## Advanced Multi-Phase Voting System

Building upon our [basic voting example](#basic-access-control-for-voting), Excubiae's advanced components enable more sophisticated access control patterns. Consider a voting system that requires registration, allows multiple votes, and includes a reward mechanism - each phase with its own validation requirements.

The advanced system leverages Excubiae's multi-phase validation through the [AdvancedChecker](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/advanced/AdvancedERC721Checker.sol) and [AdvancedPolicy](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/advanced/AdvancedERC721Policy.sol) contracts and their respective factories. This enables pre-conditions for registration, ongoing validation during voting, and post-conditions for reward distribution (see [AdvancedVoting](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/test/examples/advanced/AdvancedVoting.sol) example).

```solidity
contract AdvancedVoting {
    AdvancedPolicy public immutable POLICY;
    mapping(uint8 => uint256) public voteCounts;

    function register(uint256 tokenId) external {
        bytes[] memory _evidence = new bytes[](1);
        _evidence[0] = abi.encode(tokenId);

        POLICY.enforce(msg.sender, evidence, Check.PRE);

        emit Registered(msg.sender);
    }

    function vote(uint8 option) external {
        (bool pre, , ) = POLICY.enforced(address(this), msg.sender);

        if (!pre) revert NotRegistered();
        if (option >= 2) revert InvalidOption();

        bytes[] memory _evidence = new bytes[](1);
        _evidence[0] = abi.encode(option);

        POLICY.enforce(msg.sender, evidence, Check.MAIN);

        voteCounts[option]++;

        emit Voted(msg.sender, option);
    }

    function reward(uint256 rewardId) external {
        (bool pre, uint8 main, bool post) = POLICY.enforced(address(this), msg.sender);

        if (!pre) revert NotRegistered();
        if (main == 0) revert NotVoted();
        if (post) revert AlreadyClaimed();

        POLICY.enforce(msg.sender, new bytes[](1), Check.POST);

        emit RewardClaimed(msg.sender, rewardId);
    }
}
```

The system introduces distinct validation phases through the [Check](https://github.com/privacy-scaling-explorations/excubiae/blob/07bf4d60353f5b044cfead856d872177f9e48aff/packages/contracts/src/interfaces/IAdvancedChecker.sol#L8) enumeration:

- PRE: Validates initial registration requirements
- MAIN: Enables repeated voting with ongoing validation
- POST: Controls one-time reward claiming

This advanced implementation maintains Excubiae's core principle of separation of concerns while enabling complex state management and multi-phase validation. The complete implementation, including the corresponding checker contracts and test cases, can be found [here](https://github.com/privacy-scaling-explorations/excubiae/tree/main/packages/contracts/test/examples/advanced).

The pattern demonstrated here extends beyond voting systems. Any protocol requiring staged access control, multiple validation steps, or state-dependent permissions can leverage this same architecture. For instance, similar patterns could manage staged token unlocks, tiered protocol access, or multi-signature operations.
