A marketplace contract specified to trade a list of ERC20 pairs, including setting separate buy sell prices to introduce sell penalties etc.

The contract specifies 0x2fF33140C03011e84E745499598FBD147308d7D8 address which points to an ERC20 token on Goerli testnet initially as the 
0th index of erc20Tokens and sets the initial price to 0.0000001 eth. 

The contract also introduces reentrancy guard, ownable etc capabilities from openzeppelin to make sure payable functions are secure and admin
functions can only be applied by the owner contract.

Just replace <your_address> with your wallet address compatible with Goerli testnet EVM, and take it from there.

CoKOIN (COKE) token:
https://goerli.etherscan.io/address/0x2fF33140C03011e84E745499598FBD147308d7D8

UPDATE:
Added a gas optimal cut down version that will be used during https://medicinestore.xyz presale public launch, just replace
<token> and <owner> placeholders to make use of the contract.

Reasons for having no sale function and withdraw all eth and erc20 token functions is to withdraw funds and manually handle adding Uniswap Liquidity
when the presale ends, and to stop token hodlers from selling during presale and wait for the liquidity initiation.

The Percentages to be allocated for presale, DEX and more are listed on the website.

