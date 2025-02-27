# Introduction

## What is Excubiae?

Excubiae is a composable framework for implementing custom, attribute-based access control policies on EVM-compatible networks. At its core, it separates the concerns of **policy** definition (_what rules to enforce_) from policy **checking** (_how to validate those rules_), enabling flexible and reusable access control patterns.

The framework's mission is to enable policy enforcement through three key components: **Policies** that define access rules, **Checkers** that validate evidence, and _enforcement_ mechanisms that manage the validation flow. Built on values of modularity, reusability, and security, Excubiae provides protocol developers with building blocks to create robust access control systems.

The name "[Excubiae](https://www.nihilscio.it/Manuali/Lingua%20latina/Verbi/Coniugazione_latino.aspx?verbo=excubia&lang=IT_#:~:text=1&text=excubia%20%3D%20sentinella...%20guardia,%2C%20excubia%20%2D%20Sostantivo%201%20decl.)" comes from the ancient Roman guards who kept watch and enforced access control - an apt metaphor for a system designed to protect smart contract access through configurable policies.

## Vision

In the evolving blockchain ecosystem, protocols continuously generate new forms of verifiable evidence and proofs. While these protocols excel at producing such evidence, integrating them into access control systems outside their standard ways of doing it (e.g., APIs / apps / libs / modules) remains challenging. Excubiae aims to bridge this gap by providing a universal framework for composing and enforcing access policies based and making interoperable forms of on-chain evidence, serving as a foundational layer for access control across the ecosystem.

## Understanding Excubiae

The framework serves multiple audiences: protocol developers integrating access control into their systems, as smart contract engineers implementing custom validation logic for access control on-chain.

The architecture consists of two main types of contracts working in concert:

```
┌──────────────┐     enforces     ┌──────────────┐
│   Policy     │ ───────────────> │   Checker    │
└──────────────┘                  └──────────────┘
       │                                 │
       │ protects                        │ checks
       │                                 │
       ▼                                 ▼
┌──────────────┐                  ┌──────────────┐
│   Target     │                  │   Subject    │
└──────────────┘                  └──────────────┘
```

When a **subject** (i.e., EOA or smart contract address) attempts to access a protected **target** (i.e., smart contract protected method / resource), the enforcement flow follows a clear path:

1. Subject provides evidence to a policy.
2. Policy delegates validation to its checker.
3. Checker verifies the evidence.
4. Policy enforces the checker's decision & keeps track of the subject.

## Core Design Philosophy

Excubiae embraces modularity through a clear separation between policy and checking logic. Each component maintains a single responsibility, enabling independent auditing and evolution. The framework emphasizes reusability—checkers and policies can be shared and composed across different contexts, allowing developers to build complex access control systems from verified building blocks.

This architectural approach not only reduces development time but also strengthens security by enabling thorough component validation, gas optimization, and extension (e.g., `BaseChecker`, `AdvancedPolicy`, and more). Protocols benefit from standardized interfaces that ensure interoperability, while users experience consistent access control with clear validation requirements across different systems.

### Minimal Proxy Pattern

Under the hood, Excubiae leverages the [minimal proxy pattern with immutable args](https://github.com/vectorized/solady/blob/main/src/utils/LibClone.sol)minimal proxy pattern with immutable args for `Policy` and `Checker` contracts. This design improves efficiency, reducing gas costs for contract deployment while ensuring immutability for critical parameters.

A **Factory** contract is responsible for deploying these minimal proxy clones. Instead of deploying new instances of `Policy` and `Checker` from scratch, the factory replicates an existing implementation while enforcing correct initialization.

This results in a modular architecture where:

- A `PolicyFactory` contract ensures customizable & cheap policy instance deploy (i.e., Policy contract instance with potentially different and specific sets of parameter values).
- A `CheckerFactory` contract ensures customizable & cheap checker instance deploy (i.e., Checker contract instance with potentially different and specific sets of parameter values).
- `Policy` and `Checker` clones are initialized post-deployment only once, preventing unauthorized usage before setup. At initialization time, the args can be read from deployment bytecode and accessed / stored for further usage.

### Multi-Stage Validation

Excubiae introduces a multi-stage validation system through `AdvancedChecker`, supporting `PRE`, `MAIN`, and `POST` validation phases. This allows protocols to enforce progressively complex access control mechanisms, combining multiple validation steps into a single enforcement flow.

For instance, a protocol might require:

- **Pre-validation**: Ensuring the subject holds a specific token.
- **Main validation**: Checking additional factors such as governance approval or multi-signature confirmation.
- **Post-validation**: Logging the access event and updating permission states.

By combining minimal proxy pattern, reusability of already deployed Policy & Checker contracts, multi-phase validation, and more; Excubiae provides an efficient and flexible access control solution for smart contracts, ensuring seamless interoperability while maintaining robust security guarantees.

## Roadmap

Excubiae began as a prototype within [zk-kit.solidity](https://www.npmjs.com/package/@zk-kit/excubiae), quickly evolving into a standalone framework with its dedicated [monorepo](https://github.com/privacy-scaling-explorations/excubiae). The current [v0.3.2](https://github.com/privacy-scaling-explorations/excubiae/releases/tag/v0.3.2) release provides a robust foundation with a flexible policy framework supporting both basic and advanced verification mechanisms, the minimal proxy pattern with immutable args, the possibility to reuse already deployed instances of Checker & Policy contracts, and a set of extensions ready to use for your specific needs. The framework includes comprehensive test coverage across [Hardhat and Foundry](https://hardhat.org/hardhat-runner/docs/advanced/hardhat-and-foundry) environments, making it ready for initial adoption & integration experiments. Please, note that **we have not conducted any audit yet**.

The framework is structured in three distinct yet interconnected areas. At its core lies the smart contract framework (purple big blockk), focusing on composability, reuse, and cost-efficient deployments—this has been completed with [v0.2.0](https://github.com/privacy-scaling-explorations/excubiae/releases/tag/v0.2.0). Complementing this are integration-focused tools, including templates and registries, while user-facing applications provide contract management and exploration capabilities. This architecture allows for natural expansion while maintaining a clear separation of concerns, as represented in the diagram below. The green blocks indicate completed milestones in the latest [release](https://github.com/privacy-scaling-explorations/excubiae/releases).

:warning: Please note that the orange and blue big blocks are currently on hold. We consider Excubiae’s core features for adoption complete as of v0.3.2. However, we are still working on extensions set & tasks for deployments (yellow small blocks).

![image](https://hackmd.io/_uploads/HkWq5cDFyx.png)

With v0.3.2, Excubiae has reached a fully-fledged MVP. Moving forward, the focus will be on adoption and integration, aiming to extend the set of extensions, along with deployment scripts, guides, and examples. The orange and blue blocks are not an immediate priority but may be revisited based on adoption and team or organization-wide plans (see warning above).

Excubiae’s long-term vision is to become a standard component in protocol authentication stacks, enabling sophisticated access control through composable building blocks. The framework’s flexibility ensures it can adapt to emerging verification methods and protocols, fostering an ecosystem of reusable, audited checkers that address evolving access control requirements.

The success of this vision depends on close collaboration with early adopters and the careful expansion of the framework’s capabilities. If you are interested in contributing, integrating, or building your own Policy or Checker, or if you have feedback or comments, please reach out on the [PSE Discord](https://discord.com/invite/sF5CT5rzrR) (`🚪-excubiae` channel) or open a new [issue](https://github.com/privacy-scaling-explorations/excubiae/issues/new) / [PR](https://github.com/privacy-scaling-explorations/excubiae/compare) on the [monorepo](https://github.com/privacy-scaling-explorations/excubiae).
