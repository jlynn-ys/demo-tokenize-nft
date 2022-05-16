// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenizeNFT is ERC20 {
    uint256 public tokenPrice;
    uint256 public tokenSupply;

    // End of funding Open in days
    uint public closePeriod;
    uint public numDaysToClose;
    uint public nftId;
    uint public minAmtRaise; // need to raise at least this much

    IERC721 public nft;
    IERC20 public stableAddress; //USDC, USDT, DAI

    address public contractIssuer; //YS issuer
    mapping(address => bool) public _investors;
    mapping(address => uint) public _investorBalance;

    constructor(
        string memory _name,
        string memory _symbol,
        address _nftAddress,
        uint _nftId,
        uint _tokenPrice,
        uint _tokenSupply,
        address _stableAddress,
        uint _numDaysToClose,
        uint _minAmtRaise
    )

    ERC20(_name, _symbol) 
    {
        nftId = _nftId;
        nft = IERC721(_nftAddress);
        tokenPrice = _tokenPrice;
        tokenSupply = _tokenSupply;
        stableAddress = IERC20(_stableAddress);
        contractIssuer = msg.sender;
        numDaysToClose = _numDaysToClose;
        minAmtRaise = _minAmtRaise;
    }

    // You are an investor only when you purchase.
    // can YS admin be its own investor?
    modifier isInvestor() {
        require( _investors[msg.sender] , "Is not an investor");
        _;
    }

    modifier isIssuer() {
        require(msg.sender == contractIssuer, "Is not issuer");
        _;
    }

    /**
     Issues the number of tokens based on the NFT
     */
    function issueTokens() external {
        nft.transferFrom(msg.sender, address(this), nftId);
        closePeriod = block.timestamp + numDaysToClose * 86400;
    }

    /**
    Investor buys the number of desire tokens. 
    Checks if the fund has enough for user"s desired amt to purchase
     */
    function buyTokens(uint shareQty) external { 
        require(closePeriod > 0, "Fund not started");
        require(block.timestamp <= closePeriod, "Funding already closed");
        require(totalSupply() + shareQty <= tokenSupply, "Not enough token to buy");
        uint stableAmt = shareQty * tokenPrice;
        stableAddress.transferFrom(msg.sender, address(this), stableAmt);
        _mint(msg.sender, shareQty);
        _investorBalance[msg.sender] += shareQty;
    }

    /**
    Investor buys the number of desire tokens. 
    Checks if the fund has enough for user"s desired amt to purchase
     */
    function sellTokens(uint shareQty) isInvestor external { 
        require(closePeriod > 0, "Fund not started");
        require(block.timestamp <= closePeriod, "Funding already closed");
        require(_investorBalance[msg.sender] <= shareQty, "Investor exceed number of tokens purchased");
        payable(contractIssuer).transfer(shareQty);
        _investorBalance[msg.sender] -= shareQty;
    }

    /**
    YS takes proceeds for usage.
    Condition: fund needs to be fulfilled and period is after closePeriod (since investor can change their mind).
     */
    function withdrawProceeds() isIssuer external {
        require(block.timestamp > closePeriod, "Funding period is still open" );
        uint stableAmt = stableAddress.balanceOf(address(this));
        if (stableAmt > 0) {
            stableAddress.transfer(contractIssuer, stableAmt);
        }
    }


}



