// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import "./WrapperTest.t.sol";

contract SetPerformanceFee is WrapperTest {
    function test_SetPerformanceFee_Normal() public {
        vm.prank(owner);
        wrapper.setPerformanceFee(1e3);

        assertEq(wrapper.performanceFee(), 1e3);
    }

    function testReverts_SetPerformanceFee_NotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        wrapper.setPerformanceFee(1e3);
    }

    function testReverts_SetPerformanceFee_FeeTooHigh() public {
        vm.prank(owner);
        vm.expectRevert(Errors.FeeTooHigh.selector);
        wrapper.setPerformanceFee(1e4);
    }
}
