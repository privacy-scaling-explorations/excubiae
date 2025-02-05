# Excubiae

Excubiae is a composable framework for creating custom attribute-based access control policies on EVM-compatible networks.

It provides a set of abstract and flexible smart contracts, known as "gatekeepers," to streamline the definition of reusable criteria. These solution-agnostic contracts enforce checks against user-provided evidence and track those who satisfy the requirements.

This approach enables seamless interoperability across different protocols. For instance, a single check could combine verifiable attributes from Semaphore and MACI, ensuring flexible and composable access control. Indeed, for example, you can define criteria to verify token ownership and/or validate a zero-knowledge proof (ZKP). Using these criteria, you can create a policy to enforce the checks and integrate it seamlessly into your smart contract logic. A practical use case might involve requiring verification before registering a new voter for a poll (e.g., in a MACI-based voting system).

You can learn more in this [technical reference document](https://hackmd.io/@0xjei/B1RXoTh71e).

> [!IMPORTANT]  
> Excubiae is currently in the MVP stage. Official documentation website and audits are not yet available. Expect fast development cycles with potential breaking changes — use at your own risk! Please, refer to [release](https://github.com/privacy-scaling-explorations/excubiae/releases) section for latest changes and updates.

## Installation

Clone this repository:

```bash
git clone https://github.com/privacy-scaling-explorations/excubiae.git
```

and install the dependencies:

```bash
cd excubiae && yarn
```

## Usage

### Format

Run [Prettier](https://prettier.io/) to check formatting rules:

```bash
yarn format
```

or to automatically format the code:

```bash
yarn format:write
```

### Lint

Combination of [ESLint](https://eslint.org/) & [Solhint](https://protofire.github.io/solhint/)

```bash
yarn lint
```

### Testing

Test the code:

```bash
yarn test
```

### Build

Build all packages:

```bash
yarn build
```

Compile all contracts:

```bash
yarn compile:contracts
```

### Releases

1. Bump a new version of the package with:

```bash
yarn version:bump <strategy> <package-name>
# e.g. yarn version:bump minor excubiae-contracts
```

This step creates a commit and a git tag.

2. Push the changes to main:

```bash
git push origin main
```

3. Push the new git tag:

```bash
git push origin <package-name>-<version>
# e.g. git push origin excubiae-v0.2.0
```

After pushing the new git tag, a workflow will be triggered and will publish the package on [npm](https://www.npmjs.com/) and release a new version on Github with its changelogs automatically.
