// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./HashChallengeServiceAbstract.sol";
import "./WithRealTime.sol";

contract HashChallengeService is HashChallengeServiceAbstract, WithRealTime {
    constructor(
        uint256 _biddingTime,
        uint256 _revealTime,
        uint256 _submissionTime,
        address payable _beneficiary,
        uint256 _deposit,
        uint256 _maximumPermittedBid,
        bytes memory _hashChallenge
    )
        payable
        HashChallengeServiceAbstract(
            _biddingTime,
            _revealTime,
            _submissionTime,
            _beneficiary,
            _deposit,
            _maximumPermittedBid,
            _hashChallenge
        )
    {}
}
