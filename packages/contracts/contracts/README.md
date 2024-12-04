# Excubiae Smart Contracts

This package contains the smart contracts which define the composable framework for building custom attribute-based access control policies on Ethereum.

You can learn more in the Smart Contracts section of this [design document](https://hackmd.io/@0xjei/B1RXoTh71e#Smart-Contracts).

> [!IMPORTANT]  
> Excubiae is currently in the MVP stage. Official documentation and audits are not yet available. Expect fast development cycles with potential breaking changes — use at your own risk!

## Installation

You can install the excubiae contracts with any node package manager (`bun`, `npm`, `pnpm`,`yarn`):

```bash
bun add @excubiae/contracts
npm i @excubiae/contracts
pnpm add @excubiae/contracts
yarn add @excubiae/contracts
```

## Usage

This package is configured to support the combination of [Hardhat](https://hardhat.org/) and [Foundry](https://book.getfoundry.sh/), see the Hardhat's [documentation](https://hardhat.org/hardhat-runner/docs/advanced/hardhat-and-foundry) to learn more.

### Compile contracts

Compile the smart contracts with [Hardhat](https://hardhat.org/):

```bash
yarn compile:hardhat
```

Compile the smart contracts with Foundry's [Forge](https://book.getfoundry.sh/forge/):

```bash
yarn compile:forge
```

Run both in one command:

```bash
yarn compile
```

### Testing

Run [Mocha](https://mochajs.org/) to test the contracts (Typescript tests):

```bash
yarn test:hardhat
```

Run Foundry's [Forge](https://book.getfoundry.sh/forge/) to test the contracts (Solidity tests):

```bash
yarn test:forge
```

Run both in one command:

```bash
yarn test
```

You can also generate a test coverage report:

```bash
yarn test:coverage
```

Or a test gas report:

```bash
yarn test:report-gas
```
