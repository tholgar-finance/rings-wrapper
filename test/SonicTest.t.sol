// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import "./BaseTest.t.sol";

contract SonicTest is BaseTest {
    address constant teller = 0x5e39021Ae7D3f6267dc7995BB5Dd15669060DAe0;
    address constant scUSD = 0xd3DCe716f3eF535C5Ff8d041c1A41C3bd89b97aE;
    address constant stkscUSD = 0x4D85bA8c3918359c78Ed09581E5bc7578ba932ba;

    address operator = makeAddr("operator");

    function setUp() public virtual {
        vm.label(teller, "teller");
        vm.label(scUSD, "scUSD");
        vm.label(stkscUSD, "stkscUSD");

        vm.label(operator, "operator");
    }

    function fork() public {
        vm.createSelectFork(vm.rpcUrl("sonic"), 4_269_848);
    }

    function fork(uint256 blockNumber) public {
        vm.createSelectFork(vm.rpcUrl("sonic"), blockNumber);
    }
}
