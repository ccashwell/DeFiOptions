pragma solidity >=0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../../../contracts/feeds/ChainlinkFeed.sol";
import "../../common/mock/AggregatorV3Mock.sol";
import "../../common/mock/TimeProviderMock.sol";

abstract contract Base {

    ChainlinkFeed feed;
    
    uint[] roundIds;
    int[] answers;
    uint[] updatedAts;
    
    int price;
    bool cached;

    function beforeEachDeploy() public {

        roundIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        answers = [20, 25, 28, 18, 19, 12, 12, 13, 18, 20];
        updatedAts = 
            [1 days, 2 days, 3 days, 4 days, 5 days, 6 days, 7 days, 8 days, 9 days, 10 days];

        AggregatorV3Mock mock = new AggregatorV3Mock(roundIds, answers, updatedAts);

        TimeProviderMock time = TimeProviderMock(DeployedAddresses.TimeProviderMock());
        time.setFixedTime(10 days);

        feed = new ChainlinkFeed(
            "ETH/USD",
            address(mock), 
            address(time), 
            new uint[](0), 
            new int[](0)
        );
    }
}