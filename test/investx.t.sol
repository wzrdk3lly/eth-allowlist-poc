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
    address payable investXPool;

    function setUp() public {
        utils = new Utilities();

        accounts = utils.createUsers(3);
        investXDeployer = accounts[0];
        investXPool = accounts[1];

        vm.label(investXDeployer, "investXDeployer");

        vm.prank(investXDeployer);
        fusd = new Fusd();

        vm.prank(investXDeployer);
        investX = new InvestX(address(fusd), investXPool);
    }

    function test_transferInvestX() public {}

    function testFusdIntoInvestX() public {}
}
