var AuctionTestable = artifacts.require("AuctionTestable");
var HashChallengeServiceTestable = artifacts.require("HashChallengeServiceTestable");
var Utils = artifacts.require("Utils");

module.exports = function(deployer){

  deployer.deploy(Utils);
  deployer.link(Utils, HashChallengeServiceTestable);
  deployer.deploy(HashChallengeServiceTestable, 10, 10, 10, '0x821aEa9a577a9b44299B9c15c88cf3087F3b5544',
         1, 5000, '0x8c33002162d61fe99c7a2fb04dd86759e6951a101e7a47858cdb19a6c5249a57',{gas: 5000000, value: 5000});
 }
