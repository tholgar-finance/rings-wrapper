// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import {ERC4626} from "solady/tokens/ERC4626.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {ReentrancyGuard} from "solady/utils/ReentrancyGuard.sol";
import {AOperator} from "./abstracts/AOperator.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {UtilsLib} from "morpho/libraries/UtilsLib.sol";
import {Errors} from "./utils/Errors.sol";
import {ITeller} from "./interfaces/ITeller.sol";

/// @title Wrapper contract
/// @notice Contract to wrap a boring vault and auto compound the profits
/// @author 0xtekgrinder
contract Wrapper is ERC4626, Ownable, ReentrancyGuard, AOperator {
    using SafeTransferLib for address;
    using UtilsLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when the vesting period is updated
     */
    event VestingPeriodUpdated(uint256 newVestingPeriod);
    /**
     * @notice Event emitted when the performance fee is updated
     */
    event PerformanceFeeUpdated(uint32 newPerformanceFee);
    /**
     * @notice Event emitted when the fee recipient is updated
     */
    event FeeRecipientUpdated(address newFeeRecipient);

    /*//////////////////////////////////////////////////////////////
                          CONSTANTS VARIABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Address of the definitive asset()
     */
    address private immutable _asset;
    /**
     * @notice Name of the vault
     */
    string private _name;
    /**
     * @notice Symbol of the vault
     */
    string private _symbol;
    /**
     * @notice Address of the teller contract that will handle the deposits
     */
    address public immutable teller;
    /**
     * @notice Address of the underlying asset (e.g. SCUSD)
     */
    address public immutable underlyingAsset;

    /*//////////////////////////////////////////////////////////////
                            MUTABLE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice The vesting period of the rewards
     */
    uint64 public vestingPeriod;
    /**
     * @notice The last update of the vesting
     */
    uint64 public lastUpdate;
    /**
     * @notice The profit that is locked in the strategy
     */
    uint256 public vestingProfit;
    /**
     * @notice The performance fee taken from the harvested profits from the strategy
     */
    uint32 public performanceFee;
    /**
     * @notice The fee recipient of the performance fee
     */
    address public feeRecipient;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address initialOwner,
        address initialOperator,
        uint32 initialPerformanceFee,
        uint64 initialVestingPeriod,
        address definitiveAsset,
        address definitiveUnderlyingAsset,
        address definitiveTeller,
        string memory definitiveName,
        string memory definitiveSymbol
    ) AOperator(initialOperator) {
        _setOwner(initialOwner);

        _asset = definitiveAsset;
        _name = definitiveName;
        _symbol = definitiveSymbol;

        teller = definitiveTeller;
        underlyingAsset = definitiveUnderlyingAsset;

        performanceFee = initialPerformanceFee;
        vestingPeriod = initialVestingPeriod;
    }

    /*//////////////////////////////////////////////////////////////
                              OWNER LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Set the vesting period
     * @param newVestingPeriod The new vesting period
     */
    function setVestingPeriod(uint64 newVestingPeriod) external onlyOwner {
        vestingPeriod = newVestingPeriod;

        emit VestingPeriodUpdated(newVestingPeriod);
    }

    /**
     * @notice Set the performance fee
     * @param newPerformanceFee The new performance fee
     */
    function setPerformanceFee(uint32 newPerformanceFee) external onlyOwner {
        if (newPerformanceFee > 1e3) revert Errors.FeeTooHigh(); // 10% is the maximum performance fee

        performanceFee = newPerformanceFee;

        emit PerformanceFeeUpdated(newPerformanceFee);
    }

    /**
     * @notice Set the fee recipient of the performance fee
     * @param newFeeRecipient The new fee recipient
     */
    function setFeeRecipient(address newFeeRecipient) external onlyOwner {
        if (newFeeRecipient == address(0)) revert Errors.ZeroAddress();

        feeRecipient = newFeeRecipient;

        emit FeeRecipientUpdated(newFeeRecipient);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPERS LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Computes the current amount of locked profit
     * @dev This function is what effectively vests profits
     * @return The amount of locked profit
     */
    function lockedProfit() public view virtual returns (uint256) {
        // Get the last update and vesting delay.
        uint64 _lastUpdate = lastUpdate;
        uint64 _vestingPeriod = vestingPeriod;

        unchecked {
            // If the vesting period has passed, there is no locked profit.
            // This cannot overflow on human timescales
            if (block.timestamp >= _lastUpdate + _vestingPeriod) return 0;

            // Get the maximum amount we could return.
            uint256 currentlyVestingProfit = vestingProfit;

            // Compute how much profit remains locked based on the last time a profit was acknowledged
            // and the vesting period. It's impossible for an update to be in the future, so this will never underflow.
            return currentlyVestingProfit - (currentlyVestingProfit * (block.timestamp - _lastUpdate)) / _vestingPeriod;
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the name of the token
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                            ERC4626 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ERC4626
     * @dev asset is the definitive asset of the wrapper (stkscUSD)
     */
    function asset() public view override returns (address) {
        return _asset;
    }

    /**
     * @inheritdoc ERC4626
     */
    function totalAssets() public view override returns (uint256) {
        return super.totalAssets().zeroFloorSub(lockedProfit()); // handle rounding down of assets
    }

    /*//////////////////////////////////////////////////////////////
                            HARVEST LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Propagates a gain
     * @param gain Gain to propagate
     */
    function _handleGain(uint256 gain) internal virtual {
        if (gain != 0) {
            vestingProfit = uint128(lockedProfit() + gain);
            lastUpdate = uint32(block.timestamp);
        }
    }

    /**
     * @notice Harvest the strategy
     * @param to Address to call to withdraw the profits
     * @param inputData Arbitrary data to pass to the claimer contract
     * @dev this function will reverts if the strategy loose assets
     */
    function harvest(address to, bytes calldata inputData) public nonReentrant onlyOperatorOrOwner {
        uint256 assetsBefore = totalAssets();
        // Harvest the strategy
        (bool success, bytes memory data) = to.call(inputData);
        if (!success) {
            revert Errors.CallFailed(data);
        }
        if (totalAssets() < assetsBefore) revert Errors.HarvestLoseAssets();

        // Share the profit to the fee recipient
        address _underlyingAsset = underlyingAsset;
        uint256 profit = _underlyingAsset.balanceOf(address(this));
        if (performanceFee != 0) {
            uint256 fee = profit * performanceFee / 1e4;
            profit -= fee;
            _underlyingAsset.safeTransfer(feeRecipient, fee);
        }

        // Deposit the profit in the strategy
        _underlyingAsset.safeApprove(asset(), profit);
        uint256 sharesOut = ITeller(teller).deposit(_underlyingAsset, profit, 0);

        _handleGain(sharesOut);
    }
}
