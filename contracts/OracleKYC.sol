// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract KYCAPIConsumer is ChainlinkClient, ConfirmedOwner {
  using Chainlink for Chainlink.Request;

  uint256 public volume;
  bytes32 private jobId;
  uint256 private fee;

   event RequestVolume(bytes32 indexed requestId, uint256 volume);

  /**
    * @notice Initialize the link token and target oracle
    *
    * Polygon Mumbai Testnet details:
    * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
    * Oracle: 0xf3FBB7f3391F62C8fe53f89B41dFC8159EE9653f (Chainlink DevRel)
    * jobId: ca98366cc7314957b8c012c72f05aeeb
    *
    */
  constructor() ConfirmedOwner(msg.sender) {
    setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    setChainlinkOracle(0xf3FBB7f3391F62C8fe53f89B41dFC8159EE9653f);
    jobId = 'ca98366cc7314957b8c012c72f05aeeb';
    fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
  }
  
   /**
    * Create a Chainlink request to retrieve API response, find the target
    * data, then multiply by 1000000000000000000 (to remove decimal places from data).
    */
  function requestVolumeData() public returns (bytes32 requestId) {
    Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

    // Set the URL to perform the GET request on
    req.add('get', 'https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD');

    // Set the path to find the desired data in the API response, where the response format is:
    // {"RAW":
    //   {"ETH":
    //    {"USD":
    //     {
    //      "VOLUME24HOUR": xxx.xxx,
    //     }
    //    }
    //   }
    //  }
    // request.add("path", "RAW.ETH.USD.VOLUME24HOUR"); // Chainlink nodes prior to 1.0.0 support this format
    req.add('path', 'RAW,ETH,USD,VOLUME24HOUR'); // Chainlink nodes 1.0.0 and later support this format

    // Multiply the result by 1000000000000000000 to remove decimals
    int256 timesAmount = 10**18;
    req.addInt('times', timesAmount);

    // Sends the request
    return sendChainlinkRequest(req, fee);
  }

  /**
    * Receive the response in the form of uint256
    */
  function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
    emit RequestVolume(_requestId, _volume);
    volume = _volume;
  }

  /**
    * Allow withdraw of Link tokens from the contract
    */
  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
  }
}
