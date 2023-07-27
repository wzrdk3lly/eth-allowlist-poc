// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "forge-std/Test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {AllowlistRegistry} from "../src/contracts/eth-allowlist/contracts/Registry.sol";
import {AllowlistFactory} from "../src/contracts/eth-allowlist/contracts/Factory.sol";
import {Allowlist} from "../src/contracts/eth-allowlist/contracts/Allowlist.sol";

contract ContractBTest is Test {
    Utilities internal utils;
    Allowlist internal allowlistTemplate;
    AllowlistFactory internal allowListFactory;
    AllowlistRegistry internal allowlistRegistry;

    address payable investXDeployer;
    address payable[] users;

    function setUp() public {
        // initialize utilities
        utils = new Utilities();

        // custom utility to create new users
        users = utils.createUsers(3);

        investXDeployer = users[0];

        vm.label(investXDeployer, "InvestXDeployer");
        vm.deal(investXDeployer, 3e18);

        // deploy the allow list template address
        allowlistTemplate = new Allowlist();

        // initialize the factory using the deployed template address
        allowListFactory = new AllowlistFactory(address(allowlistTemplate));

        // initialize the registry
        allowlistRegistry = new AllowlistRegistry(
            address(allowListFactory),
            investXDeployer
        );
        // AllowlistRegistry(address _factoryAddress, address _prorocolOwnerAddress)

        // initialize investx
        // initialize implementation contract
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
}

/**
 * TODO
 * 1. [X] Setup the invest X protocol. Receives token, etc
 * 2. [X] Begin testing allowloist by adding investx to registry
 * 3. Create investx implementation contract
 * 4. Set implementation
 * 5. Add condtions
 * 6. Make a call that is not a valid one and show failed test
 */
