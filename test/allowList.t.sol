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

import {IAllowlist} from "../src/contracts/eth-allowlist/interfaces/IAllowlist.sol";

contract ContractBTest is Test {
    Utilities internal utils;
    Allowlist internal allowlistTemplate;
    AllowlistFactory internal allowListFactory;
    AllowlistRegistry internal allowlistRegistry;
    AllowlistRegistry internal allowListRegistryTest;
    Fusd internal fusd;
    InvestX internal investX;
    InvestXImplementation internal investXImplementation;

    address payable investXDeployer;
    address payable[] accounts;
    address payable fusdPool;
    address payable investXUser;
    address payable dnsSpoofer;

    function setUp() public {
        // initialize utilities
        utils = new Utilities();

        // custom utility to create new accounts
        accounts = utils.createUsers(4);

        // account[0] is the depolyer, accounts[1] is the account of the fusd-pool, acounts[2] is the user testing the implemntation
        investXDeployer = accounts[0]; // "0x123"
        fusdPool = accounts[1];
        investXUser = accounts[2];
        dnsSpoofer = accounts[3];

        vm.label(investXDeployer, "InvestXDeployer");
        vm.deal(investXDeployer, 3e18);

        vm.prank(investXDeployer);
        fusd = new Fusd();

        vm.prank(investXDeployer);
        investX = new InvestX(address(fusd), fusdPool);

        // initialize the implementation contract
        vm.prank(investXDeployer);
        investXImplementation = new InvestXImplementation(
            address(fusd),
            address(investX)
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

    /**
     * Set's the impelmentation contract within the allowList for the investX protocol
     */
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

    /**
     * Add token approval condition
     */
    function test_addCondition() public {
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

        IAllowlist.Condition memory investXCondition;

        // SEE https://ethereum.stackexchange.com/questions/130480/why-am-i-getting-index-out-of-bounds-here if you need to undertand the below

        // Lets build the condition
        investXCondition.id = "TOKEN_APPROVE_INVESTX";
        investXCondition.implementationId = "INVESTX_IMPLEMENTATION";
        investXCondition.methodName = "approve";
        investXCondition.paramTypes = new string[](2);
        investXCondition.paramTypes[0] = "address";
        investXCondition.paramTypes[1] = "uint256";
        investXCondition.requirements = new string[][](2); // change (1) -> (2) if you need to use the param checks
        investXCondition.requirements[0] = new string[](2);
        investXCondition.requirements[0][0] = "target";
        investXCondition.requirements[0][1] = "isFusd";

        investXCondition.requirements[1] = new string[](3);
        investXCondition.requirements[1][0] = "param";
        investXCondition.requirements[1][1] = "isInvestX";
        investXCondition.requirements[1][2] = "0";

        investXallowList.addCondition(investXCondition);

        uint256 conditionsLength = investXallowList.conditionsLength();

        assertEq(conditionsLength, 1);
    }

    function test_validateCalldata() public {
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

        IAllowlist.Condition memory investXCondition;

        // SEE https://ethereum.stackexchange.com/questions/130480/why-am-i-getting-index-out-of-bounds-here if you need to undertand the below

        // Method labeling and method selector requirmeents
        investXCondition.id = "TOKEN_APPROVE_INVESTX";
        investXCondition.implementationId = "INVESTX_IMPLEMENTATION";
        investXCondition.methodName = "approve";
        investXCondition.paramTypes = new string[](2);
        investXCondition.paramTypes[0] = "address";
        investXCondition.paramTypes[1] = "uint256";

        // Target requirments
        investXCondition.requirements = new string[][](2); // change (1) -> (2) if you need to use the param checks
        investXCondition.requirements[0] = new string[](2);
        investXCondition.requirements[0][0] = "target";
        investXCondition.requirements[0][1] = "isFusd";
        // Param requirements
        investXCondition.requirements[1] = new string[](3);
        investXCondition.requirements[1][0] = "param";
        investXCondition.requirements[1][1] = "isInvestX";
        investXCondition.requirements[1][2] = "0";

        investXallowList.addCondition(investXCondition);

        // generate calldata data for an approve function;
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(investX),
            20
        );

        bool isValid = allowlistRegistry.validateCalldataByOrigin(
            "InvestX.com",
            address(fusd),
            data
        );

        assertEq(isValid, true);
    }

    //function testFail_validateMaliciousCalldata
    function test_rejectMaliciousCalldata() public {
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

        IAllowlist.Condition memory investXCondition;

        // SEE https://ethereum.stackexchange.com/questions/130480/why-am-i-getting-index-out-of-bounds-here if you need to undertand the below

        // Method labeling and method selector requirmeents
        investXCondition.id = "TOKEN_APPROVE_INVESTX";
        investXCondition.implementationId = "INVESTX_IMPLEMENTATION";
        investXCondition.methodName = "approve";
        investXCondition.paramTypes = new string[](2);
        investXCondition.paramTypes[0] = "address";
        investXCondition.paramTypes[1] = "uint256";
        // Target requirments
        investXCondition.requirements = new string[][](2); // change (1) -> (2) if you need to use the param checks
        investXCondition.requirements[0] = new string[](2);
        investXCondition.requirements[0][0] = "target";
        investXCondition.requirements[0][1] = "isFusd";
        // Param requirements
        investXCondition.requirements[1] = new string[](3);
        investXCondition.requirements[1][0] = "param";
        investXCondition.requirements[1][1] = "isInvestX";
        investXCondition.requirements[1][2] = "0";

        investXallowList.addCondition(investXCondition);

        // generate malicious calldata data with an attempt to give an attacker spender approval instead of the exchanges
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            dnsSpoofer, //Should fail isInvestX check
            20
        );

        bool isValid = allowlistRegistry.validateCalldataByOrigin(
            "InvestX.com",
            address(fusd),
            data
        );

        assertEq(isValid, false);
    }

    // function test where the spoofer attempts to call transfer from or any method that insn't approve

    // play around with timelock.sol
    function test_Reregister() public {
        // Sets the block.timestamp to be 2 days in seconds
        vm.warp(2 days);

        // Perform intiial registration
        vm.startPrank(investXDeployer);
        allowlistRegistry.registerProtocol("InvestX.com");

        allowlistRegistry.initializeReregister("InvestX.com");
        uint256 blocktimeStampB4Warp = allowlistRegistry
            .reregisterTimestampByAddress(address(investXDeployer));

        console2.log("The timestamp before warp is:", blocktimeStampB4Warp);

        // represents waiting a full day since initiating a reregisration plus an extra second
        vm.warp(3 days + 1);

        uint256 blocktimeStampAfterWarp = block.timestamp;

        console2.log("The timestamp after warp is:", blocktimeStampAfterWarp);

        // create a condition array of 1

        IAllowlist.Condition[]
            memory arrayOfConditions = new IAllowlist.Condition[](1);
        // Create a condition to be added to the new allowList
        IAllowlist.Condition memory investXCondition;

        // Method labeling and method selector requirmeents
        investXCondition.id = "TOKEN_APPROVE_INVESTX";
        investXCondition.implementationId = "INVESTX_IMPLEMENTATION";
        investXCondition.methodName = "approve";
        investXCondition.paramTypes = new string[](2);
        investXCondition.paramTypes[0] = "address";
        investXCondition.paramTypes[1] = "uint256";

        // Target requirments
        investXCondition.requirements = new string[][](2); // change (1) -> (2) if you need to use the param checks
        investXCondition.requirements[0] = new string[](2);
        investXCondition.requirements[0][0] = "target";
        investXCondition.requirements[0][1] = "isFusd";
        // Param requirements
        investXCondition.requirements[1] = new string[](3);
        investXCondition.requirements[1][0] = "param";
        investXCondition.requirements[1][1] = "isInvestX";
        investXCondition.requirements[1][2] = "0";

        arrayOfConditions[0] = investXCondition;

        // create an implementation array of 1
        IAllowlist.Implementation[]
            memory arrayOfImplementations = new IAllowlist.Implementation[](1);

        // create an implementation to be addedto the implemnetation array
        IAllowlist.Implementation memory investXImplementation1 = IAllowlist
            .Implementation(
                "INVESTX_IMPLEMENTATION",
                address(investXImplementation)
            );

        arrayOfImplementations[0] = investXImplementation1;

        allowlistRegistry.reregisterProtocol(
            "InvestX.com",
            arrayOfImplementations,
            arrayOfConditions
        );
    }

    function test_RevertWhenReregisterBeforeTimelockFinish() public {
        vm.warp(block.timestamp + 2 days);
        // Perform intiial registration
        vm.startPrank(investXDeployer);
        allowlistRegistry.registerProtocol("InvestX.com");

        allowlistRegistry.initializeReregister("InvestX.com");

        // create a condition array of 1

        IAllowlist.Condition[]
            memory arrayOfConditions = new IAllowlist.Condition[](1);
        // Create a condition to be added to the new allowList
        IAllowlist.Condition memory investXCondition;

        // Method labeling and method selector requirmeents
        investXCondition.id = "TOKEN_APPROVE_INVESTX";
        investXCondition.implementationId = "INVESTX_IMPLEMENTATION";
        investXCondition.methodName = "approve";
        investXCondition.paramTypes = new string[](2);
        investXCondition.paramTypes[0] = "address";
        investXCondition.paramTypes[1] = "uint256";

        // Target requirments
        investXCondition.requirements = new string[][](2); // change (1) -> (2) if you need to use the param checks
        investXCondition.requirements[0] = new string[](2);
        investXCondition.requirements[0][0] = "target";
        investXCondition.requirements[0][1] = "isFusd";
        // Param requirements
        investXCondition.requirements[1] = new string[](3);
        investXCondition.requirements[1][0] = "param";
        investXCondition.requirements[1][1] = "isInvestX";
        investXCondition.requirements[1][2] = "0";

        arrayOfConditions[0] = investXCondition;

        // create an implementation array of 1
        IAllowlist.Implementation[]
            memory arrayOfImplementations = new IAllowlist.Implementation[](1);

        // create an implementation to be addedto the implemnetation array
        IAllowlist.Implementation memory investXImplementation1 = IAllowlist
            .Implementation(
                "INVESTX_IMPLEMENTATION",
                address(investXImplementation)
            );

        arrayOfImplementations[0] = investXImplementation1;

        // expecting this call to fail due to timelock not finishing
        vm.expectRevert(bytes("Timelock not finished"));
        allowlistRegistry.reregisterProtocol(
            "InvestX.com",
            arrayOfImplementations,
            arrayOfConditions
        );
    }
}
