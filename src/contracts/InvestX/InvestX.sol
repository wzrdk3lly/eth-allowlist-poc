// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract InvestX {
    IERC20 public fusd;
    address public fusdPool;

    constructor(address _fusd, address _fusdPool) {
        fusd = IERC20(_fusd);
        fusdPool = _fusdPool;
    }

    /**
     *
     * @param _amountIn amount of FUSD that a user transfers into the protocol
     */
    function investFusd(uint256 _amountIn) public {
        fusd.transferFrom(msg.sender, fusdPool, _amountIn);
    }
}
