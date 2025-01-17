// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import "./WrapperTest.t.sol";
import { PullerSender } from "../mock/PullerSender.t.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";

contract Harvest is WrapperTest {
    function test_Harvest_Normal(uint256 amount) public {
        amount = bound(amount, 1e6, 1000e6);

        PullerSender puller = new PullerSender();
        deal(scUSD, address(puller), amount);

        vm.prank(owner);
        wrapper.harvest(
            address(puller), abi.encodeWithSelector(PullerSender.send.selector, scUSD, address(wrapper), amount)
        );

        assertEq(IERC20(scUSD).balanceOf(address(wrapper)), 0);

        uint256 feeAmount = amount * wrapper.performanceFee() / 1e4;
        assertEq(IERC20(stkscUSD).balanceOf(address(wrapper)), amount - feeAmount);
        assertEq(IERC20(scUSD).balanceOf(wrapper.feeRecipient()), feeAmount);
        assertEq(wrapper.totalAssets(), 0);

        vm.warp(block.timestamp + wrapper.vestingPeriod() / 2);
        assertEq(wrapper.totalAssets(), (amount - feeAmount) / 2);

        vm.warp(block.timestamp + wrapper.vestingPeriod() / 2);
        assertEq(wrapper.totalAssets(), amount - feeAmount);

        vm.warp(block.timestamp + wrapper.vestingPeriod() / 2);
        assertEq(wrapper.totalAssets(), amount - feeAmount);
    }

    function testReverts_Harvest_NotOwnerOrOperator() public {
        vm.prank(alice);
        vm.expectRevert(Errors.NotOperatorOrOwner.selector);
        wrapper.harvest(alice, "");
    }

    function testReverts_Harvest_HarvestLoseAssets(uint256 amount) public {
        amount = bound(amount, 1e6, 1000e6);

        PullerSender puller = new PullerSender();
        deal(stkscUSD, address(wrapper), amount);

        vm.prank(address(wrapper));
        IERC20(stkscUSD).approve(address(puller), amount);

        vm.prank(owner);
        vm.expectRevert(Errors.HarvestLoseAssets.selector);
        wrapper.harvest(address(puller), abi.encodeWithSelector(PullerSender.pull.selector, stkscUSD, amount));
    }

    function testReverts_Harvest_CallFailed(uint256 amount) public {
        amount = bound(amount, 1e6, 1000e6);

        PullerSender puller = new PullerSender();
        deal(stkscUSD, address(wrapper), amount);

        vm.prank(owner);
        vm.expectRevert();
        wrapper.harvest(address(puller), abi.encodeWithSelector(PullerSender.pull.selector, stkscUSD, amount));
    }
}
