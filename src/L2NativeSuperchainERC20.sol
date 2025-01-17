// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@solady-v0.0.292/auth/Ownable.sol";
import {SuperchainERC20} from "@superfuse-core/L2/SuperchainERC20.sol";

/// @custom:security-contact Consult full code at https://github.com/OpenZeppelin/openzeppelin-contracts
contract L2NativeSuperchainERC20 is SuperchainERC20, Ownable {
    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;

    constructor(address owner_, string memory name_, string memory symbol_, uint8 decimals_)
    {
        _initializeOwner(owner_);
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function mintTo(address to_, uint256 amount_) external onlyOwner {
        _mint(to_, amount_);
    }
}
