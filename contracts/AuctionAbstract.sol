// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./Utils.sol";
import "./WithRealTime.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract AuctionAbstract is BaseUtils{
    struct Bid {
        bytes32 blindedBid;
        bool revealed;
    }

    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;
    uint public deposit;
    uint public maximumPermittedBid;

    mapping(address => Bid[]) public bids;
    address payable public lowestBidder;
    uint public lowestBid = 2**256 - 1;

    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    error AuctionEndAlreadyCalled();

    constructor(
        uint _biddingTime,
        uint _revealTime,
        uint _deposit,
        uint _maximumPermittedBid
    ) payable {
        require(msg.value == _maximumPermittedBid);

        biddingEnd = timestamp() + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
        deposit = _deposit;
        maximumPermittedBid = _maximumPermittedBid;
    }

    function bid(bytes32 blindedBid)
        external
        payable
        BaseUtils.onlyBefore(biddingEnd)
    {
        require(msg.value == deposit);

        bids[msg.sender].push(Bid({
            blindedBid: blindedBid,
            revealed: false
        }));
    }

    function reveal(
        uint[] calldata values,
        bytes32[] calldata salts
    )
        external
        BaseUtils.onlyAfter(biddingEnd)
        BaseUtils.onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(values.length == length);
        require(salts.length == length);

        uint refund;
        for (uint i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            if (bidToCheck.revealed)
                continue;

            (uint value, bytes32 salt) = (values[i], salts[i]);
            bytes32 current_hash = keccak256(abi.encodePacked(value, salt));

            if ((value > maximumPermittedBid) || (bidToCheck.blindedBid != current_hash)) {
                continue;
            }

            if ((!placeBid(msg.sender, value)))
                refund += deposit;

            // could have zerod out `bidToCheck.blindedBid` too in order to to save
            // some storage cost but the code is more readable with the `revealed` boolean
            bidToCheck.revealed = true;
        }

        // here, it is safe to transfer the money directly instead of using the
        // withdrawal pattern
        payable(msg.sender).transfer(refund);
    }

    /// Withdraw a bid that was overbid.
    function withdraw() external {
        uint amount = pendingReturns[msg.sender];

        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    function auctionEnd()
        external
        onlyAfter(revealEnd)
    {
        if (ended) revert AuctionEndAlreadyCalled();
        emit AuctionEnded(lowestBidder, lowestBid);
        ended = true;
    }

    function placeBid(address bidder, uint value) internal
            returns (bool success)
    {
        if (value >= lowestBid) {
            return false;
        }
        if (lowestBidder != address(0)) {
            pendingReturns[lowestBidder] += deposit;
        }
        lowestBid = value;
        lowestBidder = payable(bidder);
        return true;
    }
}
