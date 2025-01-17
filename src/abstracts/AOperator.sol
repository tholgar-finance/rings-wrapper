// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import { Errors } from "../utils/Errors.sol";
import { Ownable } from "solady/auth/Ownable.sol";

/// @author 0xtekgrinder
/// @title AOperator
/// @notice Abstract contract to allow access only to operator or owner
abstract contract AOperator is Ownable {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when a output tokens and/or ratios are updated
     */
    event OperatorUpdated(address newOperator);

    /*//////////////////////////////////////////////////////////////
                            MUTABLE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice operator caller address to allow access only to web3 function
     */
    address public operator;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyOperatorOrOwner() {
        if (msg.sender != operator && msg.sender != owner()) revert Errors.NotOperatorOrOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address initialOperator) {
        if (initialOperator == address(0)) revert Errors.ZeroAddress();

        operator = initialOperator;
    }

    /*//////////////////////////////////////////////////////////////
                               CONTRACT LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOperator(address newOperator) external onlyOwner {
        if (newOperator == address(0)) revert Errors.ZeroAddress();

        operator = newOperator;

        emit OperatorUpdated(newOperator);
    }
}
