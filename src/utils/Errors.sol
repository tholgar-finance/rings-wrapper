//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Errors {
    // General errors
    error ZeroValue();
    error ZeroAddress();
    error EmptyArray();
    error DifferentSizeArrays(uint256 length1, uint256 length2);

    // Operator errors
    error NotOperator();
    error NotOperatorOrOwner();

    // Call errors
    error CallFailed(bytes reason);

    // Fee errors
    error FeeTooHigh();
}
