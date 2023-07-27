// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract InvestXImplementation {
    IERC20 internal fusd;
    address internal investXPool;

    constructor(address _fusd, address _investXPool) {
        fusd = IERC20(_fusd);
        investXPool = _investXPool;
    }

    // function that validates the underLying token used is correct (fusd)
    function isFusd(address tokenAddress) public view returns (bool) {
        return address(fusd) == tokenAddress;
    }

    // function that validates the pool being deposited into is valid
    function isInvestXPool(address targetPool) public view returns (bool) {
        return investXPool == targetPool;
    }

    // - checks the token being passed in as a parameter has the same contract address
}
