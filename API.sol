/SPDX-License-Identifier:MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import  "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";


contract APIConsumer is ChainlinkClient, ConfirmedOwner{
    using Chainlink for Chainlink.Request;

    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;

    event RequestVolume(bytes32 indexed requestId,uint256 volume);

    constructor() ConfirmedOwner(msg.sender){
      //  setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b462478a);
      //  setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
      //  jobId="ca98366cc7314957b8c012c72f05aeeb";
      // fee=(1*LINK_DIVISIBILITY)/10 ;// 1*10**18
    }


    //Create a Chainlink request to retrieve API response, find the target data


    function requestData() public returns(bytes32 requestId){
        Chainlink.Request memory req= buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );
        //set the URL to perform the GET request on
        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD"
        );

    // set the path to find the desired data in the API response, 
    //sample response format:
    //     {
    //         "RAW":
    //         {
    //             "ETH":{
    //                 "USD":{
    //                     "VOLUME24HOUR":.....
    //                 }
    //             }
    //         }
    //     }
    req.add("path","RAW,ETH,USD,VOLUME24HOUR");

    int256 timesAmount = 10**18;
    req.addInt("times",timesAmount);

    return sendChainlinkRequest(req,fee);

}
    //receive the response in the uin256 format
    function fulfill(
        bytes32 _requestId,
        uint256 _volume
    ) public recordChainlinkFulfillment(_requestId){
        emit RequestVolume(_requestId,_volume);
        volume=_volume;
    }

    function withdrawLink() public onlyOwner{
        LinkTokenInterface link= LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender,link.balanceOf(address(this))),
            "Unable to transfer tokens"
        );
    }
}
