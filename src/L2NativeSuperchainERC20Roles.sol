// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {EnumerableRoles} from "@solady-v0.0.292/auth/EnumerableRoles.sol";
import {SuperchainERC20} from "@superfuse-core/L2/SuperchainERC20.sol";

/// @custom:security-contact Consult full code at https://github.com/OpenZeppelin/openzeppelin-contracts
contract L2NativeSuperchainERC20Roles is SuperchainERC20, EnumerableRoles {
    uint256 public constant ADMIN_ROLE = 0;
    uint256 public constant MINTER_ROLE = 1;
    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;

    constructor(address defaultAdmin_, address minter_, string memory name_, string memory symbol_, uint8 decimals_)
    {
        if (defaultAdmin_ != address(0)) {
            _setRole(defaultAdmin_, ADMIN_ROLE, true);
        }
        if (minter_ != address(0)) {
          _setRole(minter_, MINTER_ROLE, true);
        }
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

    function _authorizeSetRole(address , uint256 , bool )
        internal
        override(EnumerableRoles)
    {
        _checkRole(ADMIN_ROLE);
    }

    function mintTo(address to_, uint256 amount_) external onlyRole(MINTER_ROLE) {
        _mint(to_, amount_);
    }
}
