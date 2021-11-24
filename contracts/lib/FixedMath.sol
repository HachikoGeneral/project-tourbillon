// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

library FixedMath {
    uint256 internal constant FIXED_SCALE = 1e18;

    function fdiv(uint256 _x, uint256 _y) internal pure returns (uint256) {
        return (_x * FIXED_SCALE) / _y;
    }

    function fmul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        return (_x * _y) / FIXED_SCALE;
    }
}
