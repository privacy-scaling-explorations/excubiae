# Design

## Policy

A [Policy](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/src/policy/Policy.sol) in Excubiae acts as a gatekeeper, controlling access to protected resources through well-defined enforcement mechanisms. Think of it as a security checkpoint - it doesn't determine the rules itself, but it ensures they are properly enforced.

Each policy maintains one critical pieces of information, the [target](https://github.com/privacy-scaling-explorations/excubiae/blob/07bf4d60353f5b044cfead856d872177f9e48aff/packages/contracts/contracts/src/policy/Policy.sol#L14) address, which represents the contract or resource being protected.

Since the Policy is a "clonable" contract (extends the [Clone](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/src/proxy/Clone.sol) contract), it has a specific, base implementation of the `_initialize()` internal method - where the ownership is transferred from the sender to the factory.

The framework provides two extendable policy variants:

### [BasePolicy](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/src/policy/BasePolicy.sol)

Ideal for simple one-time validations, like token-gated access.

```solidity
function enforce(address subject, bytes memory evidence) external {
    if (enforced[subject]) revert AlreadyEnforced();
    if (!BASE_CHECKER.check(subject, evidence)) revert UnsuccessfulCheck();

    enforced[subject] = true;

    emit Enforced(subject, target, evidence);
}
```

### [AdvancedPolicy](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/src/policy/AdvancedPolicy.sol)

Supports multi-phase validation with pre-checks, main validation (potentially repeated), and post-checks.

```solidity
function enforce(address subject, bytes memory evidence, Check checkType) external {
    CheckStatus storage status = enforced[subject];

    if (checkType == Check.PRE) {
        if (SKIP_PRE) revert CannotPreCheckWhenSkipped();
        if (status.pre) revert AlreadyEnforced();
        status.pre = true;
    } else if (checkType == Check.POST) {
        if (SKIP_POST) revert CannotPostCheckWhenSkipped();
        if (status.main == 0) revert MainCheckNotEnforced();
        if (status.post) revert AlreadyEnforced();
        status.post = true;
    } else {
        if (!SKIP_PRE && !status.pre) revert PreCheckNotEnforced();
        if (!ALLOW_MULTIPLE_MAIN && status.main > 0) revert MainCheckAlreadyEnforced();
        status.main += 1;
    }

    if (!ADVANCED_CHECKER.check(subject, evidence, checkType)) revert UnsuccessfulCheck();

    emit Enforced(subject, target, evidence, checkType);
}
```

Both variants supports their own `_initialize()` internal method override (see [Guides](#guides) for more) for clone initialization after factory deployment.

This pattern ensures that:

- All access attempts are validated through the checker
- State changes only occur after successful validation
- Multiple targets can share policies efficiently
- Double-pass attempts are prevented
- The enforcement flow remains consistent across implementations

The state tracking acts as a non-cryptographically signed (dummy) nullifier, preventing subjects from repeatedly passing the same validation. This is particularly important in scenarios like voting or token claiming where double-participation must be prevented.

### Checker

A Checker in Excubiae is responsible for validating access conditions. Think of it as the rulebook that defines what constitutes valid access - it receives evidence and determines whether it meets the specified criteria. The checker remains deliberately stateless, focusing solely on validation logic. This design allows checkers to be shared across different policies and enables clear, auditable validation rules.

Please note that, also the Checker is a "clonable" contract (extends the [Clone](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/src/proxy/Clone.sol) contract).

The framework offers two checker variants: - [BaseChecker](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/src/checker/BaseChecker.sol): perfect for straightforward validations that need a single check, like verifying token ownership, and - [AdvancedChecker](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/src/checker/AdvancedChecker.sol): enables multi-phase validation with distinct checks for different stages of access control.

This pattern ensures:

- Clean separation between validation logic and state management
- Reusable validation components
- Gas-efficient operations through view functions
- Clear, auditable validation rules
- Flexible evidence handling for different validation needs

After establishing the core components (Policy and Checker), let's discuss how they work together and the key design decisions that shape the framework.

## Design Decisions

### Enforcement Flow

The interaction between policies and checkers follows a deliberate pattern to ensure secure, efficient access control. When a subject attempts to access a protected resource, the flow proceeds through several key stages:

```
1. Subject provides evidence to Policy
Evidence = abi.encode(validationData)

2. Policy delegates to Checker
check(subject, evidence) → bool

3. On success, Policy updates state
enforced[target][subject] = true

4. Target can verify enforcement
if (!policy.enforced(address(this), subject))
    revert NotAuthorized
```

This flow remains consistent whether using base or advanced components, though advanced implementations add phase-specific validation steps through the Check enum (PRE, MAIN, POST).

### Evidence-Based Validation

Excubiae adopts an evidence-based approach to validation, using encoded data rather than raw parameters:

```solidity
bytes[] memory evidence = [abi.encode(data1), abi.encode(data2)];
policy.enforce(subject, evidence);
```

This design decision provides remarkable flexibility in how validation data is structured and processed. Checkers can decode this evidence in various ways, enabling complex validation schemes without changing the core interface. The pattern also future-proofs the framework, allowing for new types of evidence and validation mechanisms while maintaining backward compatibility.

## Extensions

The framework's extensibility stems from its carefully designed abstraction layers. Developers can create new implementations by extending either base or advanced contracts, depending on their validation needs:

```solidity
contract CustomChecker is BaseChecker {
    // Some storage / state here.

    function _initialize() internal override {
        super._initialize();

        bytes memory data = _getAppendedBytes();

        // Do something with data.
    }

    function _check(
        address subject,
        bytes memory evidence
    ) internal view override returns (bool) {
        // Custom validation logic
    }
}

contract CustomAdvancedChecker is AdvancedChecker {
    // Some storage / state here.

    function _initialize() internal override {
        super._initialize();

        bytes memory data = _getAppendedBytes();

        // Do something with data.
    }

    function _checkPre(...) internal view override returns (bool) {
        // Pre-validation logic
    }

    function _checkMain(...) internal view override returns (bool) {
        // Main validation logic
    }

    function _checkPost(...) internal view override returns (bool) {
        // Post-validation logic
    }
}
```

This extensible architecture enables developers to implement custom validation logic while maintaining the framework's guarantees. New checkers can incorporate protocol-specific requirements, novel validation mechanisms, or combinations of existing checks. The consistent interface ensures that these custom implementations remain composable with the broader Excubiae ecosystem.

In fact, with the release v0.3.1, we provide an extension folder containing ready to use Checker, Policy and their respective, Factory contracts for providing unique features for your use case.

### [Semaphore](https://github.com/privacy-scaling-explorations/excubiae/tree/main/packages/contracts/contracts/extensions)

The Semaphore extension in Excubiae enhances access control by incorporating zero-knowledge proof-based identity verification using [Semaphore](https://docs.semaphore.pse.dev). Semaphore allows users to prove membership in a group without revealing their identity, supporting privacy-preserving access control mechanisms.

This extension includes two primary components:

- **[SemaphoreChecker](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/extensions/SemaphoreChecker.sol)**: Validates zero-knowledge proofs of membership.
- **[SemaphorePolicy](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/extensions/SemaphorePolicy.sol)**: Enforces access rules based on successful Semaphore proof verifications.

```
┌────────────────────┐     enforces     ┌────────────────────┐
│  SemaphorePolicy   │ ───────────────> │  SemaphoreChecker  │
└────────────────────┘                  └────────────────────┘
        │                                      │
        │ protects                             │ validates
        │                                      │
        ▼                                      ▼
┌─────────────┐                      ┌──────────────────────────┐
│    Target   │                      │   User Membership Proof  │
└─────────────┘                      └──────────────────────────┘
```

The **[SemaphoreChecker](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/extensions/SemaphoreChecker.sol)** contract extends the `BaseChecker` and is responsible for verifying zero-knowledge proofs provided by users. It ensures that the submitted proof corresponds to the correct user and group, using the Semaphore protocol.

- **Group Verification:** Validates that the proof belongs to the specified Semaphore group.
- **Prover Validation:** Ensures the proof matches the user’s address.
- **Proof Integrity:** Uses Semaphore’s built-in proof verification logic.

```solidity
function _check(address subject, bytes calldata evidence) internal view override returns (bool) {
    ISemaphore.SemaphoreProof memory proof = abi.decode(evidence, (ISemaphore.SemaphoreProof));

    uint256 _scope = proof.scope;
    address _prover = address(uint160(_scope >> 96));
    uint96 _groupId = uint96(_scope & ((1 << 96) - 1));

    if (_prover != subject) revert IncorrectProver();
    if (_groupId != groupId) revert IncorrectGroupId();
    if (!semaphore.verifyProof(_scope, proof)) revert InvalidProof();

    return true;
}
```

The **[SemaphorePolicy](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/extensions/SemaphorePolicy.sol)** contract extends `BasePolicy` to enforce access control rules based on successful Semaphore proof verifications. It ensures one-time usage of proofs through nullifier tracking.

- **Nullifier Tracking:** Prevents double usage of the same proof.
- **Proof Validation:** Calls `SemaphoreChecker` to verify proofs before granting access.

```solidity
function _enforce(address subject, bytes calldata evidence) internal override {
    ISemaphore.SemaphoreProof memory proof = abi.decode(evidence, (ISemaphore.SemaphoreProof));
    uint256 _nullifier = proof.nullifier;

    if (spentNullifiers[_nullifier]) revert AlreadySpentNullifier();

    spentNullifiers[_nullifier] = true;

    super._enforce(subject, evidence);
}
```

The **[SemaphoreCheckerFactory](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/extensions/SemaphoreCheckerFactory.sol)** streamlines the deployment of `SemaphoreChecker` instances, utilizing the minimal proxy pattern for efficient contract cloning.

**Deployment Example:**

```solidity
function deploy(address _semaphore, uint256 _groupId) public {
    bytes memory data = abi.encode(_semaphore, _groupId);
    address clone = super._deploy(data);
    SemaphoreChecker(clone).initialize();
}
```

The **[SemaphorePolicyFactory](https://github.com/privacy-scaling-explorations/excubiae/blob/main/packages/contracts/contracts/extensions/SemaphorePolicyFactory.sol)** streamlines the deployment of `SemaphorePolicy` instances, utilizing the minimal proxy pattern for efficient contract cloning.

**Deployment Example:**

```solidity
function deploy(address _checker) public {
    bytes memory data = abi.encode(msg.sender, _checker);
    address clone = super._deploy(data);
    SemaphorePolicy(clone).initialize();
}
```

## Codebase

Excubiae is structured as a [TypeScript/Solidity monorepo](https://github.com/privacy-scaling-explorations/excubiae) using [Yarn](https://yarnpkg.com/getting-started) as its package manager. The project is organized into distinct packages and applications:

```
excubiae/
├── packages/
│   ├── contracts/     # Framework implementation
```

The contracts package uniquely combines [Hardhat](https://hardhat.org/) and [Foundry](https://book.getfoundry.sh/) in a way that they can [coexist together](https://hardhat.org/hardhat-runner/docs/advanced/hardhat-and-foundry), offering developers flexibility in their testing approach. This dual-environment setup enables both JavaScript/TypeScript and Solidity-native testing patterns while maintaining complete coverage.

The framework's core implementation resides in `packages/contracts`, structured into distinct layers:

- Core contracts implementing base and advanced validation patterns, minimal proxy pattern with immutable args.
- Interface definitions ensuring consistent implementation
- Test suites demonstrating usage & integration (voting use case for base and advanced scenarios).
