pragma solidity >=0.6.0;

import "truffle/Assert.sol";
import "./Base.sol";

contract TestCreditTokenWithdraw is Base {

    function testRequestWithdrawWithSufficientFunds() public {
        
        issuer.issueTokens(address(alpha), 100 finney);
        alpha.transfer(address(beta), 20 finney);

        addErc20Stock(1 ether);
        
        beta.requestWithdraw(10 finney);
        Assert.equal(creditToken.balanceOf(address(beta)), 10 finney, "beta credit");
        Assert.equal(erc20.balanceOf(address(beta)), 10 finney, "beta balance");

        alpha.requestWithdraw(20 finney);
        Assert.equal(creditToken.balanceOf(address(alpha)), 60 finney, "alpha credit");
        Assert.equal(erc20.balanceOf(address(alpha)), 20 finney, "alpha balance");
        
        Assert.equal(creditProvider.totalTokenStock(), 970 finney, "token stock");
    }

    function testRequestWithdrawWithoutFunds() public {
        
        issuer.issueTokens(address(alpha), 100 finney);
        alpha.transfer(address(beta), 20 finney);
        
        beta.requestWithdraw(10 finney);
        alpha.requestWithdraw(20 finney);

        Assert.equal(creditToken.balanceOf(address(alpha)), 80 finney, "alpha credit");
        Assert.equal(creditToken.balanceOf(address(beta)), 20 finney, "beta credit");

        Assert.equal(erc20.balanceOf(address(alpha)), 0 finney, "alpha balance");
        Assert.equal(erc20.balanceOf(address(beta)), 0 finney, "beta balance");
        Assert.equal(creditProvider.totalTokenStock(), 0 finney, "token stock");
    }

    function testRequestWithdrawThenAddPartialFunds() public {
        
        issuer.issueTokens(address(alpha), 100 finney);
        alpha.transfer(address(beta), 20 finney);
        
        beta.requestWithdraw(10 finney);
        alpha.requestWithdraw(20 finney);

        addErc20Stock(10 finney);
        creditToken.processWithdraws();
        
        Assert.equal(creditToken.balanceOf(address(alpha)), 80 finney, "alpha credit");
        Assert.equal(creditToken.balanceOf(address(beta)), 10 finney, "beta credit");
        
        Assert.equal(erc20.balanceOf(address(alpha)), 0 finney, "alpha balance");
        Assert.equal(erc20.balanceOf(address(beta)), 10 finney, "beta balance");
        Assert.equal(creditProvider.totalTokenStock(), 0 finney, "token stock");
    }

    function testRequestWithdrawThenAddFullFunds() public {
        
        issuer.issueTokens(address(alpha), 100 finney);
        alpha.transfer(address(beta), 20 finney);
        
        beta.requestWithdraw(10 finney);
        alpha.requestWithdraw(20 finney);

        addErc20Stock(1 ether);        
        creditToken.processWithdraws();
        
        Assert.equal(creditToken.balanceOf(address(alpha)), 60 finney, "alpha credit");
        Assert.equal(creditToken.balanceOf(address(beta)), 10 finney, "beta credit");

        Assert.equal(erc20.balanceOf(address(alpha)), 20 finney, "alpha balance");
        Assert.equal(erc20.balanceOf(address(beta)), 10 finney, "beta balance");
        Assert.equal(creditProvider.totalTokenStock(), 970 finney, "token stock");
    }

    function testRequestWithdrawThenTransferBalance() public {
        
        issuer.issueTokens(address(alpha), 100 finney);
        alpha.transfer(address(beta), 20 finney);
        
        beta.requestWithdraw(10 finney);
        alpha.requestWithdraw(20 finney);

        alpha.transfer(address(beta), 80 finney);

        addErc20Stock(1 ether);  
        creditToken.processWithdraws();
        
        Assert.equal(creditToken.balanceOf(address(alpha)), 0 finney, "alpha credit");
        Assert.equal(creditToken.balanceOf(address(beta)), 90 finney, "beta credit");

        Assert.equal(erc20.balanceOf(address(alpha)), 0 finney, "alpha balance");
        Assert.equal(erc20.balanceOf(address(beta)), 10 finney, "beta balance");
        Assert.equal(creditProvider.totalTokenStock(), 990 finney, "token stock");
    }
}