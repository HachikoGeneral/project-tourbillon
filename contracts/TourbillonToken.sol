// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./lib/BlockDataProvider.sol";
import "./lib/DayMath.sol";
import "./lib/FixedMath.sol";
import "./lib/Multicall.sol";

contract TourbillonToken is ERC20, BlockDataProvider, Multicall {
    using FixedMath for uint256;
    using DayMath for uint256;

    uint256 internal constant DEFAULT_MAX_ADVANCE = 7;
    uint8 internal constant DECIMALS = 8;

    struct Stake {
        // slot 1
        uint80 stakedGears;
        uint80 stakeShares;
        uint16 duration;
        uint16 unlockedDay;
        uint16 lockedDay;
        // slot 2
        address owner;
    }

    uint256 public immutable dailyInterestRate;
    uint256 internal immutable startTime;

    uint256 public currentActiveDay;
    uint256 public totalStakedGears;
    uint256 public totalStakedShares;
    uint256 public nextDayNewShares;
    uint256 public currentDayEarnings;

    uint256 public shareRate;
    uint256 public nextEarningsAccumulator;

    mapping(uint256 => uint256) public exitSharesAt;
    mapping(uint256 => uint256) public earningsAccumulators;

    Stake[] public stakes;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _startTime,
        uint256 _dailyInterestRate
    ) ERC20(_name, _symbol) {
        startTime = _startTime;
        dailyInterestRate = _dailyInterestRate;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    function startStakeFor(
        address _recipient,
        uint256 _stakeGears,
        uint256 _newDuration
    ) external returns (uint256) {
        return _startStakeFor(_recipient, _stakeGears, _newDuration);
    }

    function startStake(uint256 _stakeGears, uint256 _newDuration) external returns (uint256) {
        return _startStakeFor(msg.sender, _stakeGears, _newDuration);
    }

    function tryDailyUpdate(uint256 _maxDaysToAdvance) public returns (bool, uint256) {
        uint256 currentDay = getCurrentLiveDay();
        uint256 currentActiveDay_ = currentActiveDay;
        uint256 daysBehind = currentDay.wsub(currentActiveDay_);
        bool isFullUpdate = _maxDaysToAdvance >= daysBehind;
        uint256 daysToAdvance = Math.min(_maxDaysToAdvance, daysBehind);
        if (daysToAdvance == 0) return (isFullUpdate, currentDay);
        uint256 finalActiveDay = currentActiveDay_.wadd(daysToAdvance);
        for (uint256 day = currentActiveDay_; day < finalActiveDay; day = day.wadd(1)) {
            _advanceSingleDay(day);
        }
        currentActiveDay = finalActiveDay.wrap16();
        return (isFullUpdate, finalActiveDay);
    }

    function getCurrentLiveDay() public view returns (uint256) {
        return (_getBlockTimestamp() - startTime) / 1 days;
    }

    function _advanceSingleDay(uint256 _day) internal {
        uint256 totalPastShares = totalStakedShares;
        uint256 dayAccumulator = nextEarningsAccumulator;
        earningsAccumulators[_day] = dayAccumulator;
        uint256 accumulatorIncrease = currentDayEarnings.fdiv(totalPastShares);
        nextEarningsAccumulator = dayAccumulator + accumulatorIncrease;
        uint256 nextDay = _day.wadd(1);
        totalStakedShares = totalPastShares + nextDayNewShares - exitSharesAt[nextDay];
        exitSharesAt[nextDay] = 0;
        nextDayNewShares = 0;
        currentDayEarnings = (totalStakedGears + totalSupply()).fmul(dailyInterestRate);
    }

    function _startStakeFor(
        address _recipient,
        uint256 _stakeGears,
        uint256 _newDuration
    ) internal returns (uint256) {
        uint256 startDay = _syncCurrentDay().wadd(1);
        _burn(msg.sender, _stakeGears);
        uint256 newStakeShares = _calculateStakeShares(_stakeGears, _newDuration);
        uint256 stakeId = _storeStake(
            startDay,
            _recipient,
            newStakeShares,
            _stakeGears,
            _newDuration
        );
        _globallyAccountStake(startDay, newStakeShares, _stakeGears, _newDuration);
        return stakeId;
    }

    function _syncCurrentDay() internal returns (uint256) {
        (bool isFullUpdate, uint256 currentDay) = tryDailyUpdate(DEFAULT_MAX_ADVANCE);
        require(isFullUpdate, "Tourb: Cannot stake while behind");
        return currentDay;
    }

    // TODO: implement calculate stake shares method
    function _calculateStakeShares(uint256 _stakeGears, uint256 _newDuration)
        internal
        returns (uint256)
    {
        return _stakeGears;
    }

    function _globallyAccountStake(
        uint256 _startDay,
        uint256 _newShares,
        uint256 _stakedGears,
        uint256 _duration
    ) internal {
        totalStakedGears += _stakedGears;
        nextDayNewShares += _newShares;
        exitSharesAt[_startDay.wadd(_duration)] += _stakedGears;
    }

    function _storeStake(
        uint256 _startDay,
        address _newOwner,
        uint256 _newStakeShares,
        uint256 _stakedGears,
        uint256 _newDuration
    ) internal returns (uint256 newStakeId) {
        newStakeId = stakes.length;
        stakes.push(
            Stake({
                stakedGears: uint80(_stakedGears),
                stakeShares: uint80(_newStakeShares),
                duration: uint16(_newDuration),
                unlockedDay: 0,
                lockedDay: uint16(_startDay),
                owner: _newOwner
            })
        );
    }
}
