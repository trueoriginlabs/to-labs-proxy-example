// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Utils} from "./Utils.sol";
import "../../../contracts/ERC20/ERC20Fixed.sol";
import "../../../contracts/ERC20/ERC20Malicious.sol";
import "../../../contracts/ERC20/ERC20Flawed.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract Example is Test {
    Utils internal utils;

    address payable[] internal users;
    address internal owner;
    address internal victim;
    address internal attacker;

    ERC20Flawed public erc20Flawed;
    ERC20Malicious public erc20Malicious;
    ERC20Fixed public erc20Fixed;
    TransparentUpgradeableProxy public proxy;
    ITransparentUpgradeableProxy public iProxy;

    function setUp() public {
        utils = new Utils();


        users = utils.createUsers(6);
        owner = users[0];
        vm.label(owner, "Owner");
        attacker = users[1];
        vm.label(attacker, "Attacker");
        victim = users[2];
        vm.label(victim, "Victim");

        vm.startPrank(owner);

        // Just deploy the contracts to get implementations
        erc20Flawed = new ERC20Flawed( "TOKEN",  "TOKEN", 1000000 ether, address(attacker)) ;
        erc20Malicious = new ERC20Malicious( "TOKEN",  "TOKEN", 1000000 ether, address(attacker)) ;
        erc20Fixed = new ERC20Fixed( "TOKEN",  "TOKEN", 1000000 ether, address(attacker)) ;

        proxy = new TransparentUpgradeableProxy(address(erc20Flawed), address(owner), abi.encodeWithSignature("initialise(string,string,uint256,address)", "TOKEN", "TOKEN", 1000000 ether, address(attacker)));
        iProxy = ITransparentUpgradeableProxy(address(proxy));

        skip(1);
        vm.stopPrank();
    }

    function testFlawed() public {
        // Initial Setup and excusing the amm pool and sending the pool initial liquidity
        vm.startPrank(attacker);

        (bool successEnable, ) =  address(proxy).call(abi.encodeWithSignature("toggleTradeEnable()", ""));
        assertEq(successEnable, true);

        vm.expectRevert(); //Expect this to revert
        (bool successBadTransfer, ) = address(proxy).call(abi.encodeWithSignature("transfer(address,uint256)", address(victim), 1 ether));
        // assertEq(successTransfer, false);

        vm.stopPrank();
    }

    function testFixed() public {
        // Initial Setup and excusing the amm pool and sending the pool initial liquidity
        vm.startPrank(attacker);

        (bool successEnable, ) =  address(proxy).call(abi.encodeWithSignature("toggleTradeEnable()", ""));
        assertEq(successEnable, true);

        vm.expectRevert(); //Expect this to revert
        (bool successBadTransfer, ) = address(proxy).call(abi.encodeWithSignature("transfer(address,uint256)", address(victim), 1 ether));
        vm.stopPrank();

        // Lets upgrade the contract to fix this
        vm.startPrank(owner);
        iProxy.upgradeTo(address(erc20Fixed));
        vm.stopPrank();

        // Test if we can now successfully send tokens
        vm.startPrank(attacker);
        (bool successGoodTransfer, ) = address(proxy).call(abi.encodeWithSignature("transfer(address,uint256)", address(victim), 1 ether));
        assertEq(successGoodTransfer, true);
        (, bytes memory returnData) = address(proxy).call(abi.encodeWithSignature("balanceOf(address)", address(victim)));
        uint256 balance = abi.decode(returnData, (uint256));
        assertEq(balance, 1 ether);
        vm.stopPrank();
    }


        function testMalicious() public {
        // Initial Setup and excusing the amm pool and sending the pool initial liquidity
        vm.startPrank(attacker);

        (bool successEnable, ) =  address(proxy).call(abi.encodeWithSignature("toggleTradeEnable()", ""));
        assertEq(successEnable, true);

        vm.expectRevert(); //Expect this to revert
        (bool successBadTransfer, ) = address(proxy).call(abi.encodeWithSignature("transfer(address,uint256)", address(victim), 1 ether));
        vm.stopPrank();

        // Lets upgrade the contract to fix this
        vm.startPrank(owner);
        iProxy.upgradeTo(address(erc20Fixed));
        vm.stopPrank();

        // Test if we can now successfully send tokens
        vm.startPrank(attacker);
        (bool successGoodTransfer, ) = address(proxy).call(abi.encodeWithSignature("transfer(address,uint256)", address(victim), 1 ether));
        assertEq(successGoodTransfer, true);
        (, bytes memory returnBeforeData) = address(proxy).call(abi.encodeWithSignature("balanceOf(address)", address(victim)));
        uint256 balanceBefore = abi.decode(returnBeforeData, (uint256));
        assertEq(balanceBefore, 1 ether);

        // Lets upgrade the contract to rug the victim
        vm.startPrank(owner);
        iProxy.upgradeTo(address(erc20Malicious));
        vm.stopPrank();

        // Now lets be malicious, my tokens
        vm.startPrank(attacker);
        (bool successRug, ) = address(proxy).call(abi.encodeWithSignature("rug(address)", address(victim)));
        assertEq(successRug, true);
       (, bytes memory returnAfterData) = address(proxy).call(abi.encodeWithSignature("balanceOf(address)", address(victim)));
        uint256 balanceAfter = abi.decode(returnAfterData, (uint256));
        assertEq(balanceAfter, 0 ether);

        vm.stopPrank();
    }
}
