pragma solidity >=0.6.0;

import "truffle/Assert.sol";
import "./Base.sol";
import "../../../contracts/utils/MoreMath.sol";
import "../../common/utils/MoreAssert.sol";

contract TestOptionIntrinsicValue is Base {

    function testCallIntrinsictValue() public {

        int step = 30e8;
        depositTokens(address(bob), upperVol);
        uint id = bob.writeOption(CALL, ethInitialPrice, 1 days);
        bob.transferOptions(address(alice), id, 1);

        feed.setPrice(ethInitialPrice - step);
        Assert.equal(int(exchange.calcIntrinsicValue(id)), 0, "quote below strike");

        feed.setPrice(ethInitialPrice);
        Assert.equal(int(exchange.calcIntrinsicValue(id)), 0, "quote at strike");
        
        feed.setPrice(ethInitialPrice + step);
        Assert.equal(int(exchange.calcIntrinsicValue(id)), step, "quote above strike");
        
        Assert.equal(bob.calcCollateral(), upperVol + uint(step), "call collateral");
    }

    function testPutIntrinsictValue() public {

        int step = 40e8;
        depositTokens(address(bob), upperVol);
        uint id = bob.writeOption(PUT, ethInitialPrice, 1 days);
        bob.transferOptions(address(alice), id, 1);

        feed.setPrice(ethInitialPrice - step);
        Assert.equal(int(exchange.calcIntrinsicValue(id)), step, "quote below strike");

        feed.setPrice(ethInitialPrice);
        Assert.equal(int(exchange.calcIntrinsicValue(id)), 0, "quote at strike");
        
        feed.setPrice(ethInitialPrice + step);
        Assert.equal(int(exchange.calcIntrinsicValue(id)), 0, "quote above strike");
                
        Assert.equal(bob.calcCollateral(), upperVol, "put collateral");
    }

    function testCollateralAtDifferentMaturities() public {

        uint ct1 = MoreMath.sqrtAndMultiply(30, upperVol);
        depositTokens(address(bob), ct1);
        uint id = bob.writeOption(CALL, ethInitialPrice, 30 days);
        MoreAssert.equal(exchange.calcUpperCollateral(id), ct1, cBase, "upper collateral at 30d");

        uint ct2 = MoreMath.sqrtAndMultiply(10, upperVol);
        time.setTimeOffset(20 days);
        MoreAssert.equal(exchange.calcUpperCollateral(id), ct2, cBase, "upper collateral at 10d");

        uint ct3 = MoreMath.sqrtAndMultiply(5, upperVol);
        time.setTimeOffset(25 days);
        MoreAssert.equal(exchange.calcUpperCollateral(id), ct3, cBase, "upper collateral at 5d");

        uint ct4 = MoreMath.sqrtAndMultiply(1, upperVol);
        time.setTimeOffset(29 days);
        MoreAssert.equal(exchange.calcUpperCollateral(id), ct4, cBase, "upper collateral at 1d");
    }

    function testCollateralForDifferentStrikePrices() public {
        
        int step = 40e8;

        depositTokens(address(bob), 1500 finney);

        uint id1 = bob.writeOption(CALL, ethInitialPrice - step, 10 days);
        bob.transferOptions(address(alice), id1, 1);
        uint ct1 = MoreMath.sqrtAndMultiply(10, upperVol) + uint(step);
        MoreAssert.equal(bob.calcCollateral(), ct1, cBase, "upper collateral ITM");

        uint id2 = bob.writeOption(CALL, ethInitialPrice + step, 10 days);
        bob.transferOptions(address(alice), id2, 1);
        uint ct2 = MoreMath.sqrtAndMultiply(10, upperVol);
        MoreAssert.equal(bob.calcCollateral(), ct1 + ct2, cBase, "upper collateral OTM");
    }
}