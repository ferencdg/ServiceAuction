// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./AuctionAbstract.sol";
import "./WithRealTime.sol";

abstract contract Auction is AuctionAbstract, WithRealTime {
    constructor(
        uint256 _biddingTime,
        uint256 _revealTime,
        uint256 _deposit,
        uint256 _maximumPermittedBid
    )
        payable
        AuctionAbstract(
            _biddingTime,
            _revealTime,
            _deposit,
            _maximumPermittedBid
        )
    {}
}
