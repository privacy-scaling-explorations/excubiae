# Excubiae Smart Contracts

This package contains the smart contracts which define the composable framework for building custom attribute-based access control policies on Ethereum.

You can learn more in the [Design](https://github.com/privacy-scaling-explorations/excubiae/tree/main/documentation/03_design.md) section of the current [documentation](https://github.com/privacy-scaling-explorations/excubiae/tree/main/documentation).

The extensions are ready to use Checker / Policy contracts that give unique features (e.g., enforcing a proof of membership for a Semaphore group with frontrunning resistance).

Please, follow the [Guides](https://github.com/privacy-scaling-explorations/excubiae/tree/main/documentation/04_guides.md) section for an explanation on how to write, integrate & deploy; your own Checker & Policy contracts.

> [!IMPORTANT]  
> Excubiae is currently in the MVP stage. Audits are not yet available. Expect fast development cycles with potential breaking changes — use at your own risk! Please, refer to [release](https://github.com/privacy-scaling-explorations/excubiae/releases) section for latest changes and updates.

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

### Deploy extensions

The package provides deployment scripts for the available extensions.

#### Semaphore

Deploy a Semaphore extension by providing the Semaphore contract address and group ID. This extension enforces membership proofs for a Semaphore group with frontrunning resistance.

Using Hardhat Ignition:

```bash
yarn deploy:semaphore-ignition --parameters '{"semaphoreAddress":"0x1234...5678","groupId":1}' --network sepolia
```

Using Hardhat task:

```bash
yarn deploy:semaphore-task --semaphore-address 0x1234...5678 --group-id 1 --network sepolia
```

Required parameters per deployment:

- `semaphoreAddress`: Address of the deployed Semaphore contract
- `groupId`: ID of the Semaphore group to check membership against
- `network`: Network to deploy to (e.g., sepolia, hardhat, mainnet)

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

### Documentation

You can generate smart contract documentation (book):

```bash
yarn docs:forge
```
