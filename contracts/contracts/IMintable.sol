// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

/**
 * @title IMintable
 * @dev Interface for contracts that support minting tokens with an ID
 */
interface IMintable {
    /**
     * @notice Mint a token to a specific address
     * @param to The address to mint the token to
     * @param id The token ID to mint
     */
    function mint(address to, uint256 id) external;
}
