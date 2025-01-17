// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";
import {DeployScript} from "@superfuse-deploy/deployer/DeployScript.sol";
import {MyERC20Votes} from "@main/MyERC20Votes.sol";
import {Vm} from "@forge-std-v1.9.1/Vm.sol";

string constant Artifact_MyERC20Votes = "MyERC20Votes.sol:MyERC20Votes";

/// @custom:security-contact Consult full internal deploy script at https://github.com/Ratimon/superfuse-forge
contract DeployMyERC20VotesScript is DeployScript {
    MyERC20Votes token;
    string name = "TestToken";
    string symbol = "TT";

    function deploy() external returns (MyERC20Votes) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        bytes memory args = abi.encode(name, symbol);
        return MyERC20Votes(DefaultDeployerFunction.deploy(deployer, "MyERC20Votes", Artifact_MyERC20Votes, args, options));
    }
}
