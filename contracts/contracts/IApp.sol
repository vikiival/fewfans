// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

/**
 * @title IApp
 * @dev Interface for LZ OApp contracts that can send strings.
 */
interface IApp {
    function sendString(uint32 _dstEid, string calldata _string, bytes calldata _options) external payable
}
