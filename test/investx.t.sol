// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.11;

import "forge-std/Test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {Fusd} from "../src/contracts/InvestX/Fusd.sol";
import {InvestX} from "../src/contracts/InvestX/InvestX.sol";

contract ContractBTest is Test {
    Fusd internal fusd;
    InvestX internal investX;
    Utilities internal utils;

    address payable[] accounts;
    address payable investXDeployer;
    address payable fusdPool;
    address payable investXUser;

    function setUp() public {
        utils = new Utilities();

        accounts = utils.createUsers(3);
        investXDeployer = accounts[0];
        fusdPool = accounts[1];
        investXUser = accounts[2];

        vm.label(investXDeployer, "investXDeployer");

        vm.prank(investXDeployer);
        fusd = new Fusd();

        vm.prank(investXDeployer);
        investX = new InvestX(address(fusd), fusdPool);
    }

    function test_transferFusd() public {
        uint256 investXUserBalanceBefore = fusd.balanceOf(investXUser);

        vm.prank(investXDeployer);
        fusd.transfer(investXUser, 10);

        uint256 investXUserBalanceAfter = fusd.balanceOf(investXUser);

        assertGt(investXUserBalanceAfter, investXUserBalanceBefore);
    }

    function test_investFusd() public {
        uint256 fusdPoolBefore = fusd.balanceOf(fusdPool);

        vm.startPrank(investXDeployer);
        fusd.approve(address(investX), 10);
        investX.investFusd(5);
        vm.stopPrank();

        uint256 fusdPoolAfter = fusd.balanceOf(fusdPool);

        assertGt(fusdPoolAfter, fusdPoolBefore);
        assertEq(fusdPoolAfter, 5);
    }
}
