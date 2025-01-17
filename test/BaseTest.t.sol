// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "forge-std/Test.sol";

contract BaseTest is Test {
    // Useful addresses
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address admin = makeAddr("admin");
    address owner = makeAddr("owner");
    address zero = address(0);
}
