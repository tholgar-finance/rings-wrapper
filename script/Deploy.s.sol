// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import { Wrapper } from "../src/Wrapper.sol";

contract DeployScript is Script {
    address constant teller = 0x5e39021Ae7D3f6267dc7995BB5Dd15669060DAe0;
    address constant scUSD = 0xd3DCe716f3eF535C5Ff8d041c1A41C3bd89b97aE;
    address constant stkscUSD = 0x4D85bA8c3918359c78Ed09581E5bc7578ba932ba;
    address constant owner = 0xb1Cf5c852b908A85624878452A3F3fDb6cE94f05;
    address constant operator = 0xC04FB43668C8C4cFb6e18dCCd0085ED98B1d4008;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(deployerPrivateKey);
        vm.startBroadcast(deployer);

        Wrapper wrapper = new Wrapper(
            owner,
            operator,
            owner,
            0, // 0 fee
            1 weeks,
            stkscUSD,
            scUSD,
            teller,
            "Wrapped stkscUSD",
            "wstkscUSD"
        );

        vm.stopBroadcast();
    }
}
