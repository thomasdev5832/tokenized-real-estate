// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RealDigital is ERC20 {
    constructor(address initialOwner)
        ERC20("Real", "BRL")
    {
        _mint(initialOwner, 1000 * 10 ** uint(decimals()));
    }
}