// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import "./WrapperTest.t.sol";

contract SetVestingPeriod is WrapperTest {
    function test_SetVestingPeriod_Normal() public {
        vm.prank(owner);
        wrapper.setVestingPeriod(2 weeks);

        assertEq(wrapper.vestingPeriod(), 2 weeks);
    }

    function testReverts_SetVestingPeriod_NotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        wrapper.setVestingPeriod(2 weeks);
    }
}
