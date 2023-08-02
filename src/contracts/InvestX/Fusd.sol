// SPDX-License-Identifier: Unlicense
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

pragma solidity 0.8.20;

contract Fusd is ERC20 {
    constructor() ERC20("FakeUSD", "FUSD") {
        _mint(msg.sender, 2000);
    }
}
