//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITeller {
    function deposit(address depositAsset, uint256 depositAmount, uint256 minimumMint)
        external
        payable
        returns (uint256 shares);
}
