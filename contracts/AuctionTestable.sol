// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./Auction.sol";
import "./AuctionAbstract.sol";
import "./WithFakeTime.sol";

contract AuctionTestable is AuctionAbstract, WithFakeTime {
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
