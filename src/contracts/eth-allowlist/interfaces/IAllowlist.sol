// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./IOwnable.sol";

interface IAllowlist is IOwnable {
    struct Condition {
        string id;
        string implementationId;
        string methodName;
        string[] paramTypes;
        string[][] requirements;
    }

    struct Implementation {
        string id;
        address addr;
    }

    function conditionsList() external view returns (Condition[] memory);

    function addConditions(Condition[] memory) external;

    function setImplementations(Implementation[] memory) external;

    function implementationById(string memory) external view returns (address);
}
