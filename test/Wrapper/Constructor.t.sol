// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import "./WrapperTest.t.sol";

contract Constructor is WrapperTest {
    function test_constructor_Normal() public view {
        assertEq(wrapper.owner(), owner);
        assertEq(wrapper.operator(), operator);
        assertEq(wrapper.performanceFee(), 5e2);
        assertEq(wrapper.vestingPeriod(), 1 weeks);
        assertEq(wrapper.feeRecipient(), owner);
        assertEq(wrapper.asset(), stkscUSD);
        assertEq(wrapper.teller(), teller);
        assertEq(wrapper.underlyingAsset(), scUSD);
        assertEq(wrapper.name(), "Wrapped stkscUSD");
        assertEq(wrapper.symbol(), "wstkscUSD");
    }
}
