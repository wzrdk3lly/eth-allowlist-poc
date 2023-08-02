// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
// import "./libraries/EnsHelper.sol";
import "./libraries/CalldataValidation.sol";
import "../../eth-allowlist/interfaces/IAllowlist.sol";

/*******************************************************
 *                      Interfaces
 *******************************************************/
interface IAllowlistFactory {
    function cloneAllowlist(string memory, address) external returns (address);
}

/*******************************************************
 *                   Main Contract Logic
 *******************************************************/
contract AllowlistRegistry {
    address public factoryAddress;
    string[] public registeredProtocols; // Array of all protocols which have successfully completed registration
    mapping(string => address) public allowlistAddressByOriginName; // Address of protocol specific allowlist
    address public protocolOwnerAddress;
    mapping(address => uint256) public reregisterTimestampByAddress; // timestamp of timelock mapped to  protocolOwnerAddress

    uint256 public MAX_TIME_DELAY = 1 days; // 86400

    constructor(address _factoryAddress, address _prorocolOwnerAddress) {
        factoryAddress = _factoryAddress;
        protocolOwnerAddress = _prorocolOwnerAddress; // ADDED to eliminate ENS testing dependency. We are assuming the ENS registration works as intended
    }

    /**
     * @notice Determine protocol owner address given an origin name
     * @param originName is the domain name for a protocol (ie. "yearn.finance")
     * @return ownerAddress Returns the address of the domain controller if the domain is registered on ENS
     */
    // function protocolOwnerAddressByOriginName(
    //     string memory originName
    // ) public view returns (address ownerAddress) {
    //     ownerAddress = EnsHelper.ownerAddressByName(originName);
    // }

    /**
     * @notice Begin protocol registration
     * @param originName is the domain name for a protocol (ie. "yearn.finance")
     * @dev Only valid protocol owners can begin registration
     * @dev Beginning registration generates a smart contract each protocol can use
     *      to manage their conditions and validation implementation logic
     * @dev Only fully registered protocols appear on the registration list
     */
    function registerProtocol(string memory originName) public {
        // Make sure caller is protocol owner
        // NOTE: We hardcoded
        // address protocolOwnerAddress = protocolOwnerAddressByOriginName(
        //     originName
        // );
        require(
            protocolOwnerAddress == msg.sender,
            "Only protocol owners can register protocols"
        );

        // Make sure protocol is not already registered
        bool protocolIsAlreadyRegistered = allowlistAddressByOriginName[
            originName
        ] != address(0);
        require(
            protocolIsAlreadyRegistered == false,
            "Protocol is already registered"
        );

        // Clone, register and initialize allowlist
        address allowlistAddress = IAllowlistFactory(factoryAddress)
            .cloneAllowlist(originName, protocolOwnerAddress);
        allowlistAddressByOriginName[originName] = allowlistAddress;

        // Register protocol
        registeredProtocols.push(originName);
    }

    /**
     * @notice Return a list of fully registered protocols
     */
    function registeredProtocolsList() public view returns (string[] memory) {
        return registeredProtocols;
    }

    /**
     *
     * @param originName domain name of the protocol to reregister an allowList
     */

    function initializeReregister(
        string memory originName
    ) public returns (uint256) {
        bool callerIsProtocolOwner = protocolOwnerAddress == msg.sender;
        bool protocolIsRegistered = allowlistAddressByOriginName[originName] !=
            address(0);

        // Only owner can re-register
        require(
            callerIsProtocolOwner,
            "Only protocol owners can replace their allowlist with a new allowlist"
        );

        // Only registered protocols can re-register
        require(protocolIsRegistered, "Protocol is not yet registered");

        // set the timestampe of the protocol
        reregisterTimestampByAddress[protocolOwnerAddress] = block.timestamp;
        return reregisterTimestampByAddress[protocolOwnerAddress];
    }

    // initiate re-register
    /**
     * @notice Allow protocol owners to override and replace existing allowlist
     * @dev This method is destructive and cannot be undone
     * @dev Protocols can only re-register if they have already registered once
     * @param originName Origin name of the protocol (ie. "yearn.finance")
     * @param implementations Array of implementations to set
     * @param conditions Array of conditions to set
     */
    function reregisterProtocol(
        string memory originName,
        IAllowlist.Implementation[] memory implementations,
        IAllowlist.Condition[] memory conditions
    ) public returns (uint256) {
        // Note: Commented out due to hardcoded protocl owner address.
        // address protocolOwnerAddress = protocolOwnerAddressByOriginName(
        //     originName
        // );
        bool callerIsProtocolOwner = protocolOwnerAddress == msg.sender;
        bool protocolIsRegistered = allowlistAddressByOriginName[originName] !=
            address(0);

        // Only owner can re-register
        require(
            callerIsProtocolOwner,
            "Only protocol owners can replace their allowlist with a new allowlist"
        );

        // create a req that registrant timelock has surpassed a day

        // Only registered protocols can re-register
        require(protocolIsRegistered, "Protocol is not yet registered");

        // Protocol needs to have initialized a reregistration
        require(
            reregisterTimestampByAddress[protocolOwnerAddress] > 0,
            "Protocol reregister never initialized"
        );

        // registered protocols after 1 day delay can re-register
        require(
            block.timestamp -
                reregisterTimestampByAddress[protocolOwnerAddress] >
                MAX_TIME_DELAY,
            "Timelock not finished"
        );

        // uint256 reregisterStamp = reregisterTimestampByAddress[
        //     protocolOwnerAddress
        // ];
        // Delete existing allowlist
        delete allowlistAddressByOriginName[originName];

        // Clone, re-register and initialize allowlist
        IAllowlistFactory allowlistFactory = IAllowlistFactory(factoryAddress);
        address allowlistAddress = allowlistFactory.cloneAllowlist(
            originName,
            address(this)
        );
        allowlistAddressByOriginName[originName] = allowlistAddress;

        // Set implementations
        IAllowlist allowlist = IAllowlist(allowlistAddress);
        allowlist.setImplementations(implementations);

        // Add conditions to new allowlist
        allowlist.addConditions(conditions);
        IAllowlist(allowlist).setOwnerAddress(protocolOwnerAddress);

        // Reset Timelock
        delete reregisterTimestampByAddress[protocolOwnerAddress];
    }

    /**
     * @notice Determine whether or not a given target and calldata is valid
     * @dev In order to be valid, target and calldata must pass the allowlist conditions tests
     * @param targetAddress The target address of the method call
     * @param data The raw calldata of the call
     * @return isValid True if valid, false if not
     */
    function validateCalldataByOrigin(
        string memory originName,
        address targetAddress,
        bytes calldata data
    ) public view returns (bool isValid) {
        address allowlistAddress = allowlistAddressByOriginName[originName];
        isValid = CalldataValidation.validateCalldataByAllowlist(
            allowlistAddress,
            targetAddress,
            data
        );
    }
}
