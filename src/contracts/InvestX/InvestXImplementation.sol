// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20;
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract InvestXImplementation {
    IERC20 internal fusd;
    address internal investX;

    /**
     *
     * @param _fusd fake usd token
     * @param _investX address for the investX protocol
     */
    constructor(address _fusd, address _investX) {
        fusd = IERC20(_fusd);
        investX = _investX;
    }

    /**
     * @notice function that validates the underLying token used is correct (fusd)
     * @param tokenAddress token address to be checked against the real fusd token. Returns false if it is not Fusd
     */
    function isFusd(address tokenAddress) public view returns (bool) {
        return address(fusd) == tokenAddress;
    }

    /**
     * @notice validates that the targetProtocol is the Official investX protocol
     * @param targetProtocol protocol that tokens will be deposited into
     */
    function isInvestX(address targetProtocol) public view returns (bool) {
        return investX == targetProtocol;
    }
}
