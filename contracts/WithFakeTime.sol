// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./BaseUtils.sol";

contract WithFakeTime is BaseUtils {
    uint256 private currTimestamp;

    function setTimestamp(uint256 newTimestamp) external {
        currTimestamp = newTimestamp;
    }

    function timestamp()
        internal
        view
        virtual
        override
        returns (uint256 seconds_since_epoch)
    {
        return currTimestamp;
    }
}
