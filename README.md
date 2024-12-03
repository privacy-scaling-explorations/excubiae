# Excubiae

Excubiae is a composable framework for building custom attribute-based access control policies on Ethereum.

The framework provides a set of common, abstract, and flexible smart contracts to simplify the creation of reusable, attribute-based criteria. These contracts, called "gatekeepers," are solution-agnostic, enforcing checks against user-provided evidence and maintaining records of those who meet the criteria.

This approach enables seamless interoperability across different protocols. For instance, a single check could combine verifiable attributes from Semaphore and MACI, ensuring flexible and composable access control based on two different protocols. Indeed, for example, you can define criteria to verify token ownership or/and validate a zero-knowledge proof (ZKP). Using these criteria, you can create a policy to enforce the checks and integrate it seamlessly into your smart contract logic. A practical use case might involve requiring verification before registering a new voter for a poll (e.g., in a MACI-based voting system).

You can learn more in this [design document](https://hackmd.io/@0xjei/B1RXoTh71e).

> [!IMPORTANT]  
> Excubiae is currently in the MVP stage. Official documentation and audits are not yet available. Expect fast development cycles with potential breaking changes — use at your own risk!

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

Build all packages & apps:

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
yarn version:bump <package-name> <version>
# e.g. yarn version:bump imt.sol 2.0.0
```

This step creates a commit and a git tag.

2. Push the changes to main:

```bash
git push origin main
```

3. Push the new git tag:

```bash
git push origin <package-name>-<version>
# e.g. git push origin excubiae-v0.1.0
```

After pushing the new git tag, a workflow will be triggered and will publish the package on [npm](https://www.npmjs.com/) and release a new version on Github with its changelogs automatically.
