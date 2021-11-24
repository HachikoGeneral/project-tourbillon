// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

import "../TourbillonToken.sol";

contract TestTourbillon is TourbillonToken {
    constructor() TourbillonToken("Test Tourbillon Token", "3T", 0, 99280250100594) {
        _mint(msg.sender, 1e6 * 1e8);
    }
}
