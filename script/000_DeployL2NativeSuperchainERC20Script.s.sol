// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";
import {DeployScript} from "@superfuse-deploy/deployer/DeployScript.sol";
import {L2NativeSuperchainERC20} from "@main/L2NativeSuperchainERC20.sol";
import {Vm} from "@forge-std-v1.9.1/Vm.sol";

string constant Artifact_L2NativeSuperchainERC20 = "L2NativeSuperchainERC20.sol:L2NativeSuperchainERC20";

/// @custom:security-contact Consult full internal deploy script at https://github.com/Ratimon/superfuse-forge
contract DeployL2NativeSuperchainERC20Script is DeployScript {
    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1);
    address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));
    L2NativeSuperchainERC20 token;
    string name = "L2NativeToken";
    string symbol = "NS";
    uint8 decimals = 18;
    address admin = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function deploy() external returns (L2NativeSuperchainERC20) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});
        bytes memory args = abi.encode(admin, name, symbol, decimals);
        return L2NativeSuperchainERC20(DefaultDeployerFunction.deploy(deployer, "L2NativeSuperchainERC20", Artifact_L2NativeSuperchainERC20, args, options));
    }
}
