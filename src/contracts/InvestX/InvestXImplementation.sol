// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract InvestXImplementation {
    IERC20 internal fusd;
    address internal investX;

    constructor(address _fusd, address _investX) {
        fusd = IERC20(_fusd);
        investX = _investX;
    }

    // function that validates the underLying token used is correct (fusd)
    function isFusd(address tokenAddress) public view returns (bool) {
        return address(fusd) == tokenAddress;
    }

    // function that validates the proper investX contract address
    function isInvestX(address targetPool) public view returns (bool) {
        return investX == targetPool;
    }

    // - checks the token being passed in as a parameter has the same contract address
}
