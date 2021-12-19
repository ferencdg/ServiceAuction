const HCSContract = artifacts.require("HashChallengeServiceTestable")
const { assert } = require('chai');
let abi = require('ethereumjs-abi')
let BN = web3.utils.BN;

contract("HashChallengeServiceTestable", function (accounts) {
  let HCS;
  let Alice;
  let Bob;
  let Charlie;
  let salt;
  let AliceDiff;
  let BobDiff;

  const maximumPermittedBid = new BN(5000);
  const deposit = new BN(1);

  async function send_bid(as_user, bid_value, eth_value, is_blind_correct)
  {
      if (is_blind_correct)
          await HCS.bid("0x" + abi.soliditySHA3(
              [ "uint", "bytes32"],
              [ bid_value, web3.utils.utf8ToHex("0".repeat(32))]
          ).toString('hex'), {value: eth_value, from: as_user, gasPrice: 0})
      else
          await HCS.bid("0x" +
              web3.utils.utf8ToHex("0".repeat(32))
              .toString('hex'), {value: eth_value, from: as_user, gasPrice: 0})
  }

  before(async function() {
    HCS = await HCSContract.deployed()
    accounts = await web3.eth.getAccounts()
    Alice = accounts[1]
    Bob = accounts[2]
    Charlie = accounts[3]
    salt = web3.utils.utf8ToHex("0".repeat(32));
    badSalt = web3.utils.utf8ToHex("1".repeat(32));
    AliceDiff = new BN(0);
    BobDiff = new BN(0);
  });

  it("Auction", async function () {

    let AliceBalanceBefore= new BN(await web3.eth.getBalance(Alice));
    let BobBalanceBefore = new BN(await web3.eth.getBalance(Bob));

    ////// Bidding phase //////
    await HCS.setTimestamp(5, {gasPrice: 0});

    // Alice -1: badSalt
    AliceDiff = AliceDiff.sub(new BN(1))
    await send_bid(Alice, 1040, 1, true);

    // Alice +0: refunded
    await send_bid(Alice, 1020, 1, true);

    // Alice -1: winning bet
    AliceDiff = AliceDiff.sub(new BN(1))
    await send_bid(Alice, 999, 1, true);

    // Bob +0: refunded
    await send_bid(Bob, 1000, 1, true);

    // Bob -1: bid is over the maximum
    BobDiff = BobDiff.sub(new BN(1))
    try{
        await send_bid(Bob, 42000, 1, true)
        assert(false)
    }
    catch(err){}

    ////// Reveal phase //////
    await HCS.setTimestamp(15,{gasPrice: 0});

    await HCS.reveal([1040, 1020, 999],[badSalt, salt, salt], {from: Alice, gasPrice: 0})
    await HCS.reveal([1000, 42000],[salt, salt], {from: Bob, gasPrice: 0})

    await HCS.withdraw({from: Alice, gasPrice: 0})
    await HCS.withdraw({from: Bob, gasPrice: 0})

    ////// Assertions //////

    let AliceBalanceAfter= new BN(await web3.eth.getBalance(Alice));
    let BobBalanceAfter = new BN(await web3.eth.getBalance(Bob));

    assert(AliceBalanceAfter.eq(AliceBalanceBefore.add(AliceDiff)))
    assert(BobBalanceAfter.eq(BobBalanceBefore.add(BobDiff)))
  });

  it("Solution submission", async function ()
  {
    let AliceBalanceBefore= new BN(await web3.eth.getBalance(Alice));
    let BobBalanceBefore = new BN(await web3.eth.getBalance(Bob));
    let CharlieBalanceBefore = new BN(await web3.eth.getBalance(Charlie));

    await HCS.setTimestamp(25,{gasPrice: 0});
    // service provider immediately receives the payout
    await HCS.submitSolution("Block42", {gasPrice: 0, from: Alice});
    await HCS.setTimestamp(35,{gasPrice: 0});
    // beneficiary receives
    // 1. all the slashed deposits
    // 2. the initial funding sent to the contract minus the funds sent to the
    //    service provider
    await HCS.claimRemainingEth();

    ////// Assertions //////

    let AliceBalanceAfter= new BN(await web3.eth.getBalance(Alice));
    let BobBalanceAfter = new BN(await web3.eth.getBalance(Bob));
    let CharlieBalanceAfter = new BN(await web3.eth.getBalance(Charlie));

    let lowestBid = await HCS.lowestBid();
    assert(AliceBalanceBefore.add(lowestBid).add(deposit).eq(AliceBalanceAfter))
    assert(BobBalanceBefore.eq(BobBalanceAfter))
    // Charie's new balance = Charie's new balance + maximumPermittedBid - lowestBid
    // + slashed deposits(2)
    assert(CharlieBalanceBefore.add(maximumPermittedBid).sub(lowestBid).add(new BN(2)).eq(CharlieBalanceAfter))
  })
});
