// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "forge-std/Test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {AllowlistRegistry} from "../src/contracts/eth-allowlist/contracts/Registry.sol";
import {AllowlistFactory} from "../src/contracts/eth-allowlist/contracts/Factory.sol";
import {Allowlist} from "../src/contracts/eth-allowlist/contracts/Allowlist.sol";
import {Fusd} from "../src/contracts/InvestX/Fusd.sol";
import {InvestX} from "../src/contracts/InvestX/InvestX.sol";
import {InvestXImplementation} from "../src/contracts/InvestX/InvestXImplementation.sol";

contract ContractBTest is Test {
    Utilities internal utils;
    Allowlist internal allowlistTemplate;
    AllowlistFactory internal allowListFactory;
    AllowlistRegistry internal allowlistRegistry;
    Fusd internal fusd;
    InvestX internal investX;
    InvestXImplementation internal investXImplementation;

    address payable investXDeployer;
    address payable[] accounts;
    address payable investXPool;
    address payable investXUser;

    function setUp() public {
        // initialize utilities
        utils = new Utilities();

        // custom utility to create new accounts
        accounts = utils.createUsers(3);

        // account[0] is the depolyer, accounts[1] is the account of the fusd-pool, acounts[2] is the user testing the implemntation
        investXDeployer = accounts[0];
        investXPool = accounts[1];
        investXUser = accounts[2];

        vm.label(investXDeployer, "InvestXDeployer");
        vm.deal(investXDeployer, 3e18);

        vm.prank(investXDeployer);
        fusd = new Fusd();

        vm.prank(investXDeployer);
        investX = new InvestX(address(fusd), investXPool);

        // initialize the implementation contract
        vm.prank(investXDeployer);
        investXImplementation = new InvestXImplementation(
            address(fusd),
            investXPool
        );

        // deploy the allow list template address
        allowlistTemplate = new Allowlist();

        // initialize the factory using the deployed template address
        allowListFactory = new AllowlistFactory(address(allowlistTemplate));

        // initialize the registry
        allowlistRegistry = new AllowlistRegistry(
            address(allowListFactory),
            investXDeployer
        );
    }

    /**
     * Test to register "InvestX.com" to the allowList
     */
    function test_RegisterInvestX() public {
        vm.prank(investXDeployer);
        allowlistRegistry.registerProtocol("InvestX.com");

        string[] memory registeredProtocolList;
        registeredProtocolList = allowlistRegistry.registeredProtocolsList();

        assertEq(registeredProtocolList[0], "InvestX.com");
    }

    function test_setImplementation() public {
        // investXDeployer can be the only one to interact with their allowList
        vm.startPrank(investXDeployer);
        allowlistRegistry.registerProtocol("InvestX.com");

        Allowlist investXallowList = Allowlist(
            allowlistRegistry.allowlistAddressByOriginName("InvestX.com")
        );

        investXallowList.setImplementation(
            "INVESTX_IMPLEMENTATION",
            address(investXImplementation)
        );
    }
}

/**
 * TODO
 * 1. [X] Setup the invest X protocol. Receives token, etc
 * 2. [X] Begin testing allowloist by adding investx to registry
 * 3. [x] Create investx implementation contract
 * 4. Set implementation
 * 5. Add condtions
 * 6. Make a call that is not a valid one and show failed test
 */
