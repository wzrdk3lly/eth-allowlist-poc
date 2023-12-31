// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * Temporary protocol ownership contract... TODO: Implement DNSSEC validator on Fantom
 */
contract ProtocolOwnership {
    address public ownerAddress;
    mapping(string => address) public ownerAddressByName;

    constructor() {
        ownerAddress = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Caller is not owner");
        _;
    }

    function setOwnerAddress(address newOwnerAddress) public onlyOwner {
        ownerAddress = newOwnerAddress;
    }

    function setProtocolOwnerAddress(
        string memory name,
        address protocolAddress
    ) public onlyOwner {
        ownerAddressByName[name] = protocolAddress;
    }
}
// @audit-info - This may be where the timelock should be implemented. If a malicious actor is added as a protocol owner, I believe they can also add faulty conditions.
