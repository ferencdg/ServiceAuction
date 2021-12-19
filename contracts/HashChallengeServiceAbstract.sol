// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./Auction.sol";
import "./AuctionAbstract.sol";
import "./BaseUtils.sol";
import "./Utils.sol";

abstract contract HashChallengeServiceAbstract is AuctionAbstract
{
    uint public submissionEnd;
    bytes hashChallenge;
    string public solution;
    bool public solutionFound;
    bool public solutionSubmitted;
    address payable beneficiary;

    event SolutionFound(string solution);
    event WrongSolutionSubmitted();

    constructor(
        uint _biddingTime,
        uint _revealTime,
        uint _submissionTime,
        address payable _beneficiary,
        uint _deposit,
        uint _maximumPermittedBid,
        bytes memory _hashChallenge
    ) AuctionAbstract(_biddingTime, _revealTime, _deposit, _maximumPermittedBid) payable
    {
        require(_hashChallenge.length <= 32);
        require(_hashChallenge.length > 0);

        beneficiary = _beneficiary;
        submissionEnd = revealEnd + _submissionTime;
        hashChallenge = _hashChallenge;
    }

    function submitSolution(string calldata candidateSolution) public
        BaseUtils.onlyAfter(revealEnd)
        BaseUtils.onlyBefore(submissionEnd)
    {
        require(lowestBidder != address(0));
        require(msg.sender == lowestBidder);
        require(!solutionSubmitted);

        solutionSubmitted = true;

        bytes32 solutionHash = keccak256(abi.encodePacked(candidateSolution));
        if ( Utils.compareBytes(Utils.sliceBytes32(solutionHash, uint8(32) - (uint8)(hashChallenge.length), 32), hashChallenge))
        {
            emit SolutionFound(solution);
            solutionFound = true;
            solution = candidateSolution;
            lowestBidder.transfer(lowestBid + deposit);

            // We cannot pay out the remaining balance to the auction creator
            // with the `transfer` function, as he could reverse the transaction
            // and preventing the service provider to get his money.
            // By updating pendingReturns, the auction creator can withdraw
            // the remaing balance before `submissionEnd`.
            pendingReturns[beneficiary] = address(this).balance;
        }
        else {
            emit WrongSolutionSubmitted();
            beneficiary.transfer(address(this).balance);
        }
    }

    // anyone can claim the remaining Eth,
    // but only the autction creator is payed out
    function claimRemainingEth() public
        BaseUtils.onlyAfter(submissionEnd)
    {
        beneficiary.transfer(address(this).balance);
    }
}
