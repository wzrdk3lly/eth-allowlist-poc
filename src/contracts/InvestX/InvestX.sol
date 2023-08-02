// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

/**
 *
 * @notice simple contract that allows a user to depsoit fusd into the fusd pool.
 */
contract InvestX {
    IERC20 public fusd;
    address public fusdPool;

    /**
     *
     * @param _fusd fake usd token
     * @param _fusdPool EOA that represents a pool
     */
    constructor(address _fusd, address _fusdPool) {
        fusd = IERC20(_fusd);
        fusdPool = _fusdPool;
    }

    /**
     *
     * @param _amountIn amount of FUSD that a user transfers into the protocolls
     */
    function investFusd(uint256 _amountIn) public {
        fusd.transferFrom(msg.sender, fusdPool, _amountIn);
        // Assum this is a real protocol and more things happen to the Pool
    }
}
