// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Volcano Airdrop
 * @notice Distributes 10 VLN to up to 100,000 unique wallets.
 * @dev This contract does not mint tokens. It must be pre-funded with 1,000,000 VLN.
 */
contract VolcanoAirdrop is Ownable {
    /// @notice ERC20 interface for VLN token
    IERC20 public immutable vln;

    /// @notice Fixed amount of tokens distributed per eligible wallet (10 VLN)
    uint256 public constant TOKENS_PER_ADDRESS = 10 * 1e18;

    /// @notice Maximum number of unique claims allowed
    uint256 public constant MAX_CLAIMS = 100_000;

    /// @notice Tracks addresses that have already claimed the airdrop
    mapping(address => bool) public hasClaimed;

    /// @notice Number of successful claims made
    uint256 public totalClaims;

    /// @notice Emitted when an address successfully claims tokens
    event TokensClaimed(address indexed recipient);

    /**
     * @dev Initializes the airdrop with the address of the VLN token.
     * @param _vlnAddress Address of the deployed VolcanoToken contract (ERC20).
     */
    constructor(address _vlnAddress) Ownable(msg.sender) {
        require(_vlnAddress != address(0), "Invalid token address");
        vln = IERC20(_vlnAddress);
    }

    /**
     * @notice Allows a unique wallet to claim 10 VLN tokens.
     * @dev Blocks smart contracts and repeat claims. Reverts if cap is reached or transfer fails.
     */
    function claim() external {
        require(msg.sender == tx.origin, "No contracts allowed");
        require(!hasClaimed[msg.sender], "Already claimed");
        require(totalClaims < MAX_CLAIMS, "Airdrop completed");

        hasClaimed[msg.sender] = true;
        totalClaims++;

        require(
            vln.transfer(msg.sender, TOKENS_PER_ADDRESS),
            "Token transfer failed"
        );

        emit TokensClaimed(msg.sender);
    }

    /**
     * @notice Allows the owner to withdraw any remaining VLN tokens after the airdrop ends.
     * @param to The address to receive the leftover VLN tokens.
     */
    function withdrawRemaining(address to) external onlyOwner {
        require(totalClaims >= MAX_CLAIMS, "Airdrop still active");
        uint256 remaining = vln.balanceOf(address(this));
        require(vln.transfer(to, remaining), "Withdraw failed");
    }
}
