// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";
import {DeployScript} from "@superfuse-deploy/deployer/DeployScript.sol";
import {L2NativeSuperchainERC20Roles} from "@main/L2NativeSuperchainERC20Roles.sol";
import {Vm} from "@forge-std-v1.9.1/Vm.sol";

string constant Artifact_L2NativeSuperchainERC20Roles = "L2NativeSuperchainERC20Roles.sol:L2NativeSuperchainERC20Roles";

/// @custom:security-contact Consult full internal deploy script at https://github.com/Ratimon/superfuse-forge
contract DeployL2NativeSuperchainERC20RolesScript is DeployScript {
    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1);
    address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));
    L2NativeSuperchainERC20Roles token;
    string name = "L2NativeToken";
    string symbol = "NS";
    uint8 decimals = 18;
    address defaultAdmin = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address minter = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function deploy() external returns (L2NativeSuperchainERC20Roles) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});
        bytes memory args = abi.encode(defaultAdmin, minter, name, symbol, decimals);
        return L2NativeSuperchainERC20Roles(DefaultDeployerFunction.deploy(deployer, "L2NativeSuperchainERC20Roles", Artifact_L2NativeSuperchainERC20Roles, args, options));
    }
}
