// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.11;

import "forge-std/Test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {Fusd} from "../src/contracts/InvestX/Fusd.sol";
import {InvestX} from "../src/contracts/InvestX/InvestX.sol";
import {InvestXImplementation} from "../src/contracts/InvestX/InvestXImplementation.sol";

contract ContractBTest is Test {
    Fusd internal fusd;
    InvestX internal investX;
    Utilities internal utils;
    InvestXImplementation internal investXImplementation;

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

        vm.prank(investXDeployer);
        investXImplementation = new InvestXImplementation(
            address(fusd),
            address(investX)
        );
    }

    function test_isFusd() public {
        vm.prank(investXDeployer);
        bool isVault = investXImplementation.isFusd(address(fusd));

        assertEq(isVault, true);
    }

    function testFail() public {
        vm.prank(investXDeployer);
        bool isVault = investXImplementation.isFusd(address(investX));

        assertEq(isVault, true);
    }

    function test_isInvestX() public {
        vm.prank(investXDeployer);
        bool isinvestX = investXImplementation.isInvestX(address(investX));

        assertEq(isinvestX, true);
    }

    function testFail_isInvestX() public {
        vm.prank(investXDeployer);
        bool isinvestX = investXImplementation.isInvestX(address(fusd));

        assertEq(isinvestX, true);
    }
}
