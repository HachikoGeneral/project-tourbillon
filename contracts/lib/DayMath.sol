// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

library DayMath {
    uint256 internal constant DAYS_WRAP = 1 << 16;

    function wadd(uint256 _a, uint256 _b) internal pure returns (uint256) {
        unchecked {
            return (_a + _b) % DAYS_WRAP;
        }
    }

    function wsub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        unchecked {
            return (_a - _b) % DAYS_WRAP;
        }
    }

    function wrap16(uint256 _a) internal pure returns (uint16) {
        return uint16(_a);
    }
}
