// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

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

    function addInvestor(address user) 
        public {
        _investors[user] = true;
    }

    function removeInvestor(address user)
        isInvestor
        public {
        _investors[user] = false;   
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
    Checks if the fund has enough for user's desired amt to purchase
     */
    function buyTokens(uint shareQty) external { 
        require(closePeriod > 0, 'Fund not started');
        require(block.timestamp <= closePeriod, 'Funding already closed');
        require(totalSupply() + shareQty <= tokenSupply, 'Not enough token to buy');
        uint stableAmt = shareQty * tokenPrice;
        stableAddress.transferFrom(msg.sender, address(this), stableAmt);
        _mint(msg.sender, shareQty);
        addInvestor(msg.sender);
    }

    /**
    Investor buys the number of desire tokens. 
    Checks if the fund has enough for user's desired amt to purchase
     */
    function sellTokens(uint shareQty) isInvestor external { 
        require(closePeriod > 0, 'Fund not started');
        require(block.timestamp <= closePeriod, 'Funding already closed');
        require(totalSupply() + shareQty <= tokenSupply, 'Not enough token to buy');
        uint stableAmt = shareQty * tokenPrice;
        stableAddress.transferFrom(msg.sender, address(this), stableAmt);
        _mint(msg.sender, shareQty);
        removeInvestor(msg.sender);
    }

    /**
    YS takes proceeds for usage.
    If there is leftover of unissued tokens, should we create LP, escrow, ideas what to do?
     */
    // function withdrawProceeds() isIssuer external {
    //     require()
    // }


}



