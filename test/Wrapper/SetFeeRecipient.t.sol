// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import "./WrapperTest.t.sol";

contract SetFeeRecipient is WrapperTest {
    function test_SetFeeRecipient_Normal() public {
        vm.prank(owner);
        wrapper.setFeeRecipient(alice);

        assertEq(wrapper.feeRecipient(), alice);
    }

    function testReverts_SetFeeRecipient_NotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        wrapper.setFeeRecipient(alice);
    }

    function testReverts_SetFeeRecipient_ZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(Errors.ZeroAddress.selector);
        wrapper.setFeeRecipient(zero);
    }
}
