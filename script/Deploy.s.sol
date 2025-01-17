// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import { Wrapper } from "../src/Wrapper.sol";

contract DeployScript is Script {
    address constant teller = 0x49AcEbF8f0f79e1Ecb0fd47D684DAdec81cc6562;
    address constant scUSD = 0x3bcE5CB273F0F148010BbEa2470e7b5df84C7812;
    address constant stkscUSD = 0x455d5f11Fea33A8fa9D3e285930b478B6bF85265;
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
            "Wrapped stkscETH",
            "wstkscETH"
        );
        console.log("Wrapper deployed at:", address(wrapper));

        vm.stopBroadcast();
    }
}
