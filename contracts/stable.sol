// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// create some USDC for users
// if testing use this or we need to change to USDC address
// 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
contract Stablecoin is ERC20 {
    constructor() ERC20("USDC Stable", "USDC") {}

    function mint(address to, uint amount) external {
        _mint(to, amount);
    }
}