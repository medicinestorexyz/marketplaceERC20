A marketplace contract specified to trade a list of ERC20 pairs, including setting separate buy sell prices to introduce sell penalties etc.

The contract specifies 0x2fF33140C03011e84E745499598FBD147308d7D8 address which points to an ERC20 token on Goerli testnet initially as the 
0th index of erc20Tokens and sets the initial price to 0.0000001 eth. 

The contract also introduces reentrancy guard, ownable etc capabilities from openzeppelin to make sure payable functions are secure and admin
functions can only be applied by the owner contract.

CoKOIN (COKE) token:
https://goerli.etherscan.io/address/0x2fF33140C03011e84E745499598FBD147308d7D8
