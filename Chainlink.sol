// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkPriceOracle{
    AggregatorV3Interface internal priceFeed;

    constructor(){

        priceFeed=AggregatorV3Interface(0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910);
    }

    function getLatestPricefeed() public view returns(int){
        (uint80 roundId,
        int price,
        uint startedAt,
        uint timestamp,
        uint80 answeredInRound)= priceFeed.latestRoundData();

        //for BTC/ETH price is scaled up by 10^18
        return price/1e18;
        
    }
}
