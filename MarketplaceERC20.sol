// SPDX-License-Identifier: GNU General Public License v3.0
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


contract Marketplace is Ownable(<your_address>), ReentrancyGuard {
    using Math for uint256;

    // 9000000
    // 0.00000009 eth
    uint256 public erc20TokenSellPriceDefault = 9 * 10**10;
    // 0.0000001 eth
    uint256 public erc20TokenPriceDefault = 10 * 10**10 wei;

    address[] public erc20Tokens = [0xfad325dbf70fd2b15b77d5085c937c35e265182a];
    uint256[] public erc20TokenPrices = [erc20TokenPriceDefault];
    uint256[] public erc20TokenSellPrices = [erc20TokenSellPriceDefault];

    mapping(address => bool) adminsList;

    event TokenBought(
      uint256 _tokenIndex, 
      address _buyerAddress,
      uint256 _amountBought
    );

    event TokenSold(
      uint256 _tokenIndex, 
      address _sellerAddress,
      uint256 _amountSold
    );
    
    constructor(
    ) {
    }

    modifier adminOnly() {
        require(adminsList[msg.sender] == true, 'You do not have rights');
        _;
    }

    function getTokenIndex(address _add) internal view returns (uint256) {
        uint256 index;
        for (index = 0; index < erc20Tokens.length; index++) {
            if (erc20Tokens[index] == _add) {
                return index;
            }
        }
        require(index != type(uint256).max, 'Invalid token index');
        return type(uint256).max;
    }

    function setTokenPrice(address _erc20Token, uint256 _newPrice) external adminOnly {
        require(_newPrice > 0, 'Price is incorrect');
        uint256 index = getTokenIndex(_erc20Token);
        erc20TokenPrices[index] = _newPrice;
    }

    function addNewERC20Token(address _token, uint256 _newPrice) external onlyOwner {
        erc20Tokens.push(_token);
        erc20TokenPrices.push(_newPrice);
    }

    /**
     * @dev buy Tokens from marketplace
     * ether will be charged from user account
     */
    function buyTokensCheckPrice(uint256 index, uint256 tokensAmount) public view returns(uint256) {
        return (tokensAmount * erc20TokenPrices[index]);
    }
    function buyTokens(address _token, uint256 tokensAmount) external payable nonReentrant {
        uint256 index = getTokenIndex(_token);
        require(msg.value >= buyTokensCheckPrice(index, tokensAmount), 'Incorrect amount');
        IERC20(erc20Tokens[index]).approve(address(this), tokensAmount);
        IERC20(erc20Tokens[index]).transferFrom(address(this), msg.sender, tokensAmount);
        emit TokenBought(index, msg.sender, tokensAmount);
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
    * @notice Allow users to sell tokens for ETH
    */
    function sellTokensCheckPrice(uint256 index, uint256 tokenAmountToSell) public view returns(uint256) {
        return tokenAmountToSell * erc20TokenSellPrices[index];
    }
    /**
     * requires you to call IERC20(erc20Tokens[index]).approve(address(this), tokenAmountToSell);
     * separately from the ERC20 contract in the frontend
     */ 
    function sellTokens(uint256 index, uint256 tokenAmountToSell) external nonReentrant {
        // Check that the requested amount of tokens to sell is more than 0
        require(tokenAmountToSell > 0, "Specify an amount of token greater than zero");

        // Check that the user's token balance is enough to do the swap
        uint256 userBalance = IERC20(erc20Tokens[index]).balanceOf(msg.sender);
        require(userBalance >= tokenAmountToSell * 10 ** 18, "Your balance is lower than the amount of tokens you want to sell");

        // Check that the Vendor's balance is enough to do the swap
        uint256 amountOfETHToTransfer = sellTokensCheckPrice(index, tokenAmountToSell);
        uint256 ownerETHBalance = address(this).balance;
        require(ownerETHBalance >= amountOfETHToTransfer, "Vendor has not enough funds to accept the sell request");
        
        (bool sent) = IERC20(erc20Tokens[index]).transferFrom(msg.sender, address(this), tokenAmountToSell  * 10 ** 18);
        require(sent, "Failed to transfer tokens from user to vendor");


        (sent,) = msg.sender.call{value: amountOfETHToTransfer}("");
        require(sent, "Failed to send ETH to the user");
        emit TokenSold(index, msg.sender, tokenAmountToSell);
    }

    /**
     * @dev Adds admin
     * can be used only by contract owner
     */
    function addAdmin(address _admin) external onlyOwner {
        adminsList[_admin] = true;
    }

    /**
    * @dev Owner withdraws balance wherever to address is
    */
    function withdrawAllBalance(address payable to) public onlyOwner {
        require(address(this).balance > 0, "Balance is zero, you cannot withdraw");
        to.transfer(address(this).balance);
    }

    function withdrawAllTokenBalance(uint256 index) public onlyOwner {
        uint256 balance = IERC20(erc20Tokens[index]).balanceOf(address(this));
        IERC20(erc20Tokens[index]).approve(address(this), balance);
        IERC20(erc20Tokens[index]).transferFrom(address(this), msg.sender, balance);
    }
}
