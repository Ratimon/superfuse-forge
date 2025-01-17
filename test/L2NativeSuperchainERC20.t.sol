// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DeployL2NativeSuperchainERC20Script} from "@script/000_DeployL2NativeSuperchainERC20Script.s.sol";
import {ERC20} from "@solady-v0.0.292/tokens/ERC20.sol";
import {IDeployer, getDeployer} from "@superfuse-deploy/deployer/DeployScript.sol";
import {IERC20} from "@openzeppelin-v0.5.0.2/token/ERC20/IERC20.sol";
import {IERC7802} from "@superfuse-core/interfaces/L2/IERC7802.sol";
import {IOwnable} from "@contracts-bedrock/universal/interfaces/IOwnable.sol";
import {ISuperchainERC20} from "@superfuse-core/interfaces/L2/ISuperchainERC20.sol";
import {L2NativeSuperchainERC20} from "@main/L2NativeSuperchainERC20.sol";
import {Ownable} from "@solady-v0.0.292/auth/Ownable.sol";
import {Predeploys} from "@superfuse-core/libraries/Predeploys.sol";
import {SuperchainERC20} from "@superfuse-core/L2/SuperchainERC20.sol";
import {Test} from "@forge-std-v1.9.1/Test.sol";
import {console} from "@forge-std-v1.9.1/console.sol";

contract L2NativeSuperchainERC20Test is Test {
    address alice;
    address bob;
    IDeployer deployerProcedue;
    address internal constant ZERO_ADDRESS = address(0);
    address internal constant SUPERCHAIN_TOKEN_BRIDGE = Predeploys.SUPERCHAIN_TOKEN_BRIDGE;
    address internal constant MESSENGER = Predeploys.L2_TO_L2_CROSS_DOMAIN_MESSENGER;
    L2NativeSuperchainERC20 public l2NativeSuperchainERC20;
    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1);
    address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoBroadcast(false);

        console.log("Setup L2NativeSuperchainERC20 ... ");

        DeployL2NativeSuperchainERC20Script l2NativeSuperchainERC20Deployments = new DeployL2NativeSuperchainERC20Script();
        l2NativeSuperchainERC20 = l2NativeSuperchainERC20Deployments.deploy();

        deployerProcedue.deactivatePrank();
    }

    function test_constructor() public view {
        assertEq(l2NativeSuperchainERC20.name(), "L2NativeToken");
        assertEq(l2NativeSuperchainERC20.symbol(), "NS");
        assertEq(l2NativeSuperchainERC20.decimals(), 18);
    }

    function _mockAndExpect(address _receiver, bytes memory _calldata, bytes memory _returned)
        internal
    {
        vm.mockCall(_receiver, _calldata, _returned);
        vm.expectCall(_receiver, _calldata);
    }

    function testFuzz_crosschainMint_callerNotBridge_reverts(address _caller, address _to, uint256 _amount)
        public
    {
        // Ensure the caller is not the bridge
        vm.assume(_caller != SUPERCHAIN_TOKEN_BRIDGE);

        // Expect the revert with 'Unauthorized' selector
        vm.expectRevert(ISuperchainERC20.Unauthorized.selector);

        // Call the 'mint' function with the non-bridge caller
        vm.prank(_caller);
        l2NativeSuperchainERC20.crosschainMint(_to, _amount);
    }

    function testFuzz_crosschainMint_succeeds(address _to, uint256 _amount)
        public
    {
        // Ensure '_to' is not the zero address
        vm.assume(_to != ZERO_ADDRESS);

        _amount = bound(_amount, 0, type(uint208).max);

        // Get the total supply and balance of '_to' before the mint to compare later on the assertions
        uint256 _totalSupplyBefore = l2NativeSuperchainERC20.totalSupply();
        uint256 _toBalanceBefore = l2NativeSuperchainERC20.balanceOf(_to);

        // Look for the emit of the 'Transfer' event
        vm.expectEmit(address(l2NativeSuperchainERC20));
        emit IERC20.Transfer(ZERO_ADDRESS, _to, _amount);

        // Look for the emit of the 'CrosschainMint' event
        vm.expectEmit(address(l2NativeSuperchainERC20));
        emit IERC7802.CrosschainMint(_to, _amount, SUPERCHAIN_TOKEN_BRIDGE);

        // Call the 'mint' function with the bridge caller
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        l2NativeSuperchainERC20.crosschainMint(_to, _amount);

        // Check the total supply and balance of '_to' after the mint were updated correctly
        assertEq(l2NativeSuperchainERC20.totalSupply(), _totalSupplyBefore + _amount);
        assertEq(l2NativeSuperchainERC20.balanceOf(_to), _toBalanceBefore + _amount);
    }

    function testFuzz_crosschainBurn_callerNotBridge_reverts(address _caller, address _from, uint256 _amount)
        public
    {
        /// Ensure the caller is not the bridge
        vm.assume(_caller != SUPERCHAIN_TOKEN_BRIDGE);

        // Expect the revert with 'Unauthorized' selector
        vm.expectRevert(ISuperchainERC20.Unauthorized.selector);

        // Call the 'burn' function with the non-bridge caller
        vm.prank(_caller);
        l2NativeSuperchainERC20.crosschainBurn(_from, _amount);
    }

    function testFuzz_crosschainBurn_succeeds(address _from, uint256 _amount)
        public
    {
        // Ensure '_from' is not the zero address
        vm.assume(_from != ZERO_ADDRESS);

        _amount = bound(_amount, 0, type(uint208).max);

        // Mint some tokens to '_from' so then they can be burned
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        l2NativeSuperchainERC20.crosschainMint(_from, _amount);

        // Get the total supply and balance of '_from' before the burn to compare later on the assertions
        uint256 _totalSupplyBefore = l2NativeSuperchainERC20.totalSupply();
        uint256 _fromBalanceBefore = l2NativeSuperchainERC20.balanceOf(_from);

        // Look for the emit of the 'Transfer' event
        vm.expectEmit(address(l2NativeSuperchainERC20));
        emit IERC20.Transfer(_from, ZERO_ADDRESS, _amount);

        // Look for the emit of the 'CrosschainBurn' event
        vm.expectEmit(address(l2NativeSuperchainERC20));
        emit IERC7802.CrosschainBurn(_from, _amount, SUPERCHAIN_TOKEN_BRIDGE);

        // Call the 'burn' function with the bridge caller
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        l2NativeSuperchainERC20.crosschainBurn(_from, _amount);

        // Check the total supply and balance of '_from' after the burn were updated correctly
        assertEq(l2NativeSuperchainERC20.totalSupply(), _totalSupplyBefore - _amount);
        assertEq(l2NativeSuperchainERC20.balanceOf(_from), _fromBalanceBefore - _amount);
    }

    function testRenounceOwnership() public {
        vm.expectEmit(true, true, true, true);
        emit IOwnable.OwnershipTransferred(owner, address(0));

        vm.prank(owner);
        l2NativeSuperchainERC20.renounceOwnership();
        assertEq(l2NativeSuperchainERC20.owner(), address(0));
    }

    function testFuzz_testTransferOwnership(address _newOwner) public {
        vm.assume(_newOwner != owner);
        vm.assume(_newOwner != ZERO_ADDRESS);

        vm.expectEmit(true, true, true, true);
        emit IOwnable.OwnershipTransferred(owner, _newOwner);

        vm.prank(owner);
        l2NativeSuperchainERC20.transferOwnership(_newOwner);

        assertEq(l2NativeSuperchainERC20.owner(), _newOwner);
    }

    function testFuzz_mintTo_succeeds(address _to, uint256 _amount) public {
        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(address(0), _to, _amount);

        vm.prank(owner);
        l2NativeSuperchainERC20.mintTo(_to, _amount);

        assertEq(l2NativeSuperchainERC20.totalSupply(), _amount);
        assertEq(l2NativeSuperchainERC20.balanceOf(_to), _amount);
    }

    function testFuzz_transfer_succeeds(address _sender, uint256 _amount) public {
        vm.assume(_sender != ZERO_ADDRESS);
        vm.assume(_sender != bob);

        vm.prank(owner);
        l2NativeSuperchainERC20.mintTo(_sender, _amount);

        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(_sender, bob, _amount);

        vm.prank(_sender);
        assertTrue(l2NativeSuperchainERC20.transfer(bob, _amount));
        assertEq(l2NativeSuperchainERC20.totalSupply(), _amount);

        assertEq(l2NativeSuperchainERC20.balanceOf(_sender), 0);
        assertEq(l2NativeSuperchainERC20.balanceOf(bob), _amount);
    }

    function testFuzz_transferFrom_succeeds(address _spender, uint256 _amount)
        public
    {
        vm.assume(_spender != ZERO_ADDRESS);
        vm.assume(_spender != bob);
        vm.assume(_spender != alice);

        vm.prank(owner);
        l2NativeSuperchainERC20.mintTo(bob, _amount);

        vm.prank(bob);
        l2NativeSuperchainERC20.approve(_spender, _amount);

        vm.prank(_spender);
        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(bob, alice, _amount);
        assertTrue(l2NativeSuperchainERC20.transferFrom(bob, alice, _amount));

        assertEq(l2NativeSuperchainERC20.balanceOf(bob), 0);
        assertEq(l2NativeSuperchainERC20.balanceOf(alice), _amount);
    }

    function testFuzz_transferInsufficientBalance_reverts(address _to, uint256 _mintAmount, uint256 _sendAmount)
        public
    {
        vm.assume(_mintAmount < type(uint256).max);
        _sendAmount = bound(_sendAmount, _mintAmount + 1, type(uint256).max);

        vm.prank(owner);
        l2NativeSuperchainERC20.mintTo(address(this), _mintAmount);

        vm.expectRevert(ERC20.InsufficientBalance.selector);
        l2NativeSuperchainERC20.transfer(_to, _sendAmount);
    }

    function testFuzz_transferFromInsufficientAllowance_reverts(address _to, address _from, uint256 _approval, uint256 _amount)
        public
    {
        vm.assume(_from != ZERO_ADDRESS);
        vm.assume(_approval < type(uint256).max);
        _amount = _bound(_amount, _approval + 1, type(uint256).max);

        vm.prank(owner);
        l2NativeSuperchainERC20.mintTo(_from, _amount);

        vm.prank(_from);
        l2NativeSuperchainERC20.approve(address(this), _approval);

        vm.expectRevert(ERC20.InsufficientAllowance.selector);
        l2NativeSuperchainERC20.transferFrom(_from, _to, _amount);
    }

    function testFuzz_mintTo_succeeds(address _minter, address _to, uint256 _amount)
        public
    {
        vm.assume(_minter != owner);

        // Expect the revert with 'Unauthorized' selector
        vm.expectRevert(Ownable.Unauthorized.selector);

        vm.prank(_minter);
        l2NativeSuperchainERC20.mintTo(_to, _amount);
    }
}
