// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import "../SonicTest.t.sol";
import "../../src/Wrapper.sol";

contract WrapperTest is SonicTest {
    Wrapper wrapper;

    function setUp() public virtual override {
        SonicTest.setUp();
        fork();

        wrapper = new Wrapper(
            owner,
            operator,
            owner,
            5e2, // 5% fee
            1 weeks,
            stkscUSD,
            scUSD,
            teller,
            "Wrapped stkscUSD",
            "wstkscUSD"
        );
    }
}
