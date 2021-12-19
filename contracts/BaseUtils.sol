// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

abstract contract BaseUtils {
    error TooEarly(uint256 time);
    error TooLate(uint256 time);

    modifier onlyBefore(uint256 time) {
        if (timestamp() >= time) revert TooLate(time);
        _;
    }

    modifier onlyAfter(uint256 time) {
        if (timestamp() <= time) revert TooEarly(time);
        _;
    }

    function timestamp()
        internal
        view
        virtual
        returns (uint256 seconds_since_epoch);
}
