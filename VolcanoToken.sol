// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
* @title Volcano Token (VLN)
* @notice Utility token with a fixed supply, designed for hackathons and community use.
*/
contract VolcanoToken is ERC20, Ownable {
    uint8 private constant _DECIMALS = 18;
    uint256 private constant _INITIAL_SUPPLY = 1_000_000_000 * 10 ** uint256(_DECIMALS);

    /**
     * @dev The constructor initializes name, symbol, supply and property.
     */
    constructor() ERC20("Volcano Token", "VLN") Ownable(msg.sender) {
        _mint(msg.sender, _INITIAL_SUPPLY);
    }

    /**
     * @notice Reward an address with tokens from the owner's balance.
     */
    function awardTokens(address recipient, uint256 amount) external onlyOwner {
        require(balanceOf(owner()) >= amount, "Insufficient owner balance");
        require(recipient != address(0), "Invalid recipient");
        _transfer(owner(), recipient, amount);
    }

    /**
     * @notice Returns the number of decimal places in the token (18).
     */
    function decimals() public pure override returns (uint8) {
        return _DECIMALS;
    }
}
