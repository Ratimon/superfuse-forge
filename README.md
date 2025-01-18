<h1>Keep Optimistic and be Superchain dApp developer!! </h1>

- [Quickstart](#quickstart)
- [What is it for](#what-is-it-for)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [Acknowledgement](#acknowledgement)

>[!NOTE]
> You can find our relevant examples [`here`](https://github.com/Ratimon/superfuse-contracts-examples). Geneated contract code from the Superfuse Wizard is stored here due to documentation and testing purpose.

## Quickstart

### Installation

Add the `superfuse-forge` using your favorite package manager, e.g., with pnpm:

```bash
pnpm init
pnpm add superfuse-forge
pnpm install
``` 

### Quick Guide

1. Set your working environment with **foundry** : 

```bash
forge init my-project;
``` 

2.  Add the `superfuse-forge` using your favorite package manager, e.g., with Yarn or pnpm:


```sh
yarn add -D superfuse-forge
```
```sh
pnpm add superfuse-forge
```

3. Adding `remappings.txt` with following line:

```txt
@superfuse-core/=node_modules/superfuse-forge/src
@superfuse-deploy/=node_modules/superfuse-forge/script
@superfuse-test/=node_modules/test/

@forge-std-v1.9.1/=node_modules/superfuse-forge/lib/forge-std-v1.9.1/src/
@solady-v0.0.292/=node_modules/superfuse-forge/lib/solady-v0.0.292/src/

@openzeppelin-v0.4.7.3/=node_modules/superfuse-forge/lib/openzeppelin-v0.4.7.3/contracts/
@openzeppelin-v0.5.0.2/=node_modules/superfuse-forge/lib/openzeppelin-v0.5.0.2/contracts/

@contracts-bedrock/=node_modules/superfuse-forge/lib/optimism/packages/contracts-bedrock/src/
```

>[!TIP]
> We use @<Lib>-v<Lib-Version>/ as a convention to avoid any naming conflicts with your previously installed libararies ( i.e. `@solady-0.0.292/` vs `@solady/`)

>[!NOTE]
>  You can check out dependencies'versions [`here`](https://github.com/Ratimon/superfuse-forge/blob/main/package.json#L31). For example, all OPStack's contracts are based on [`v1.10.0`](https://github.com/ethereum-optimism/optimism/tree/v1.10.0/packages/contracts-bedrock).


4. Copy `.env` as following.

```sh
MNEMONIC="test test test test test test test test test test test junk"
# local network 's default private key so it is still not exposed
DEPLOYER_PRIVATE_KEY=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
DEPLOYER_ADDRESS=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
```

4. Modify  `.gitignore` as following.

```diff
# ...
+node_modules/
```

5. Copy a set of deploy scripts example except [`/deployer`](./script/deployer/):

```sh
rsync -av --exclude='deployer/' node_modules/superfuse-forge/script/ script/
```

Alternatively:
```sh
cp node_modules/superfuse-forge/script/* script/
```

Now, copy a test suite:
```sh
cp node_modules/superfuse-forge/test/DeployAll.t.sol test/
```

6. Compile and run test:

This will take a while to compile:
```sh
forge t
```

>[!TIP]
>Behind the scene, the test suite works by replicating the same environment as production script, because it utilizes the same deployment logic script inside `setUp()` as following:

```ts

/** ... */

// deployment logic
import {DeployMyERC20VotesScript} from "@script/000_DeployMyERC20VotesScript.s.sol";

contract ERC20VotesTest is Test {

    /** ... */

    function setUp() external {

         /** ... */

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoBroadcast(false);

        console.log("Setup MyERC20Votes ... ");

        DeployMyERC20VotesScript myERC20VotesDeployments = new DeployMyERC20VotesScript();
        myERC20Votes = myERC20VotesDeployments.deploy();

        deployerProcedue.deactivatePrank();

    }
    /** ... */

}
```

>[!NOTE]
> You can chekout [this](https://github.com/Ratimon/redprint-forge/blob/main/script/example/000_DeployMyERC20VotesScript.s.sol)