// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TourbillonToken is ERC20 {
    uint8 internal constant DECIMALS = 8;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }
}
