// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

abstract contract BlockDataProvider {
    function _getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    function _getBlockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }
}
