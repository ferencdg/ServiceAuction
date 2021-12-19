// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./BaseUtils.sol";

contract WithRealTime is BaseUtils {
    function timestamp()
        internal
        view
        virtual
        override
        returns (uint256 seconds_since_epoch)
    {
        return block.timestamp;
    }
}
