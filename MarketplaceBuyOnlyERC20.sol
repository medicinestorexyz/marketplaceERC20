// SPDX-License-Identifier: GNU General Public License v3.0
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


contract Marketplace is Ownable(<owner>), ReentrancyGuard {
    using Math for uint256;

    // 0.00008 eth
    uint256 public erc20TokenPriceDefault = 8 * 10**12 wei;

    address[] public erc20Tokens = [<token>];
    uint256[] public erc20TokenPrices = [erc20TokenPriceDefault];

    event TokenBought(
      uint256 _tokenIndex, 
      address _buyerAddress,
      uint256 _amountBought
    );

    event WithdrawAllETH();
    event WithdrawAllTokens();
    
    constructor(
    ) {
    }

    function setTokenPriceByIndex(uint256 index, uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, 'Price is incorrect');
        erc20TokenPrices[index] = _newPrice;
    }

    function addNewERC20Token(address _token, uint256 _newBuyPrice) external onlyOwner {
        require(_newBuyPrice > 0, 'Price is incorrect');
        erc20Tokens.push(_token);
        erc20TokenPrices.push(_newBuyPrice);
    }

    /**
     * @dev buy Tokens from marketplace
     * ether will be charged from user account
     */
    function buyTokensCheckPrice(uint256 index, uint256 tokensAmount) public view returns(uint256) {
        return (tokensAmount * erc20TokenPrices[index]);
    }

    /**
     * @dev buy Tokens from marketplace by index, to test gas spend difference
     * ether will be charged from user account
     */
    function buyTokensByIndex(uint256 index, uint256 tokensAmount) external payable nonReentrant {
        require(msg.value >= buyTokensCheckPrice(index, tokensAmount), 'Incorrect amount');
        IERC20(erc20Tokens[index]).approve(address(this), tokensAmount * 10 ** 18);
        IERC20(erc20Tokens[index]).transferFrom(address(this), msg.sender, tokensAmount * 10 ** 18);
        emit TokenBought(index, msg.sender, tokensAmount);        
    }

    /**
    * @dev Owner withdraws balance wherever to address is
    */
    function withdrawAllBalance(address payable to) public onlyOwner {
        require(address(this).balance > 0, "Balance is zero, you cannot withdraw");
        to.transfer(address(this).balance);
        emit WithdrawAllETH();
    }

    function withdrawAllTokenBalance(uint256 index) public onlyOwner {
        uint256 balance = IERC20(erc20Tokens[index]).balanceOf(address(this));
        IERC20(erc20Tokens[index]).approve(address(this), balance);
        IERC20(erc20Tokens[index]).transferFrom(address(this), msg.sender, balance);
        emit WithdrawAllTokens();
    }
}
