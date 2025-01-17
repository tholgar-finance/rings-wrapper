// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";

contract PullerSender {
    using SafeTransferLib for address;

    function pull(address token, uint256 amount) public {
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function send(address token, address to, uint256 amount) public {
        token.safeTransfer(to, amount);
    }
}
