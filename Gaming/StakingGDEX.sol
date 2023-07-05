/**
=**************************************************************************************************************************************************************=
#@*==========================================================================================================================================================+@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-             .=+***********:                                     -**********+*-                                                                           :@#
#@-               -#@@@@@@@@@@@*.                                 -%@@@@@@@@@@@*:                                                                            :@#
#@-                 -#@@@@@@@@@@@*:                             -%@@@@@@@@@@@*:                                                                              :@#
#@-                   -#@@@@%-=*%@@*.                         -%@@#+-=@@@@@*:                                                                                :@#
#@-                     -#@@@%.===++#+:                     -**+===:-@@@@*:                                                                                  :@#
#@-                       -#@@#.+***+=-.                   :==+***=:@@@*:                                                                                    :@#
#@-                         =#@*.+*+++***+=:.         .-=+**++++*=.%@*:                                                                                      :@#
#@-                           -#+.+*+++++++**++++++++**++++++++*=.#*:                                                                                        :@#
#@-                             --:+*+++++++++++++++++++++++++*+.=:    =+++++++++++++++*-#++++++++++++++++=: :=++++++++++++++++#*+++++=   .++++++#           :@#
#@-                                :+++++++++++++++++++++++++*+.      -#+++++++++++++++*-@+++++++++++++++++#:%++++++++++++++*%*:+%*+++++.-**+++##-           :@#
#@-                                 =++*****+++++++++********+-       =*+++++++++++++++*-%=++++++++++++++++#-#+++++++++++++#+:   -##++++**+++*#+.            :@#
#@-                                 ++*****+:........++******+:       =*====#=====#++++*-%=+++*:::::::=*+++#-#+++*+--------:      .*#*++++++#%-              :@#
#@-                                 ++*****+.        ---------:       =*+++=%    .%=+++*-%=++++       -*+++#-#+++++++++++++#        =%+++++*#.               :@#
#@-                                 ++*****+.  ***************:       =*+++=%.....%=+++*-@=++++       -*+++#-#++++++++++++=#       :**++++++*+.              :@#
#@-                                 ++*****+.  *+++++*********-       =*++++*******++++*-@=+++#=======+*+++#-#+++*********##     .=**++***++***:             :@#
#@-                                 ++*****+.        :#*******-       =*+++++++++++++++*-@=++++++++++++++++#-#+++++++++++++++=  :******%=##**+**=            :@#
#@-                                 +*******=---------+*******-       :#*++++++++++*+++*-@++++++++++++****##.##**************+*+#****##:  =%******:          :@#
#@-                                -**************************#:     -+=***********+****-+=================. .================+++===++     :+====+-          :@#
#@-                             --:*****************************.::  :#%#*****####******-                                                                    :@#
#@-                           -#*.***********========+***********.#*.  +%#************##:                                                                    :@#
#@-                         -%@*.*******+=-.          .:-=*#******.#@*: -*+++++++++++++-                                                                     :@#
#@-                       -%@@#.**#*=-:.                   .:=+***+:%@@*.                                                                                    :@#
#@-                     -#@@@%:=---=*+:                    .-*+=--=--@@@@*:                                                                                  :@#
#@-                   -%@@@@%:-+%@@*:                         -#@@#+-+@@@@@*.                                                                                :@#
#@-                 -#@@@@@@@@@@@*:                            .=#@@@@@@@@@@@*:                                                                              :@#
#@-               -%@@@@@@@@@@@*:                                 -#@@@@@@@@@@@*.                                                                            :@#
#@-              -++++++++++++:                                    .=++++++++++++.                                                                           :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@+::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::=@#
+%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract StakingGDEX is Ownable {

    struct UserStakingInfo {
        uint stakedAmount;
        uint updatedTime;
    }

    struct UserLockInfo {
        uint lockedAmount;
        uint lockedTime;
    }

    struct UnstakingStatus {
        uint requestedTime;
        bool isRequested;
    }

    address public stakedToken;
    address public passportContract;
    uint public cooldownPeriod;
    uint public forceUnlockingPenalty;
    uint public constant YEAR = 365 days;
    uint public constant PENALTY_DENOMINATOR = 10000;

    mapping(uint => UserStakingInfo) public usersStakingInfo;
    mapping(uint => mapping(uint => UserLockInfo)) public usersLockInfo;
    mapping(uint => UnstakingStatus) public userUnstakingStatus;
    mapping(uint => bool) public isSupportPeriod;

    event UpdatedStakingToken(address indexed oldToken, address indexed newToken);
    event Staked(address indexed user, uint amount, uint gamerId);
    event Locked(address indexed user, uint amount, uint period, uint gamerId);
    event RequestedUnstaking(address indexed user, bool isRequested, uint gamerId);
    event Unstaked(address indexed user, uint gamerId);
    event Unlocked(address indexed user, uint period, uint  gamerId);
    event UpgradedLock(address indexed user, uint previousPeriod, uint newPeriod, uint gamerId);
    event ForceUnlock(address indexed user, uint period, uint gamerId);
    event SetSupportedPeriod(uint period, bool isValid);
    event UpdatedCooldownPeriod(uint oldOne, uint newOne);
    event UpdatedPassportContract(address gameAddress);
    event UpdatedForceUnlockingPenalty(uint newPenalty);

    modifier isValidPeriod(uint period) {
        require(isSupportPeriod[period], "Not supported period");
        _;
    }

    constructor(address _stakedToken, address _passportContract) {
        require(_stakedToken != address(0), "Invalid token address");
        require(_passportContract != address(0), "Invalid passport address");
        stakedToken = _stakedToken;
        passportContract = _passportContract;
        cooldownPeriod = 7 days;
        forceUnlockingPenalty = 3000;
    }

    function setCooldownPeriod(uint newPeriod) external onlyOwner {
        uint oldPeriod = cooldownPeriod;
        require(oldPeriod != newPeriod, "Already the same period");
        cooldownPeriod = newPeriod;
        emit UpdatedCooldownPeriod(oldPeriod, newPeriod);
    }

    function setStakingToken(address newToken) external onlyOwner {
        require(newToken != address(0), "Invalid address");
        address oldToken = stakedToken;
        require(oldToken != newToken, "Already the same token");
        stakedToken = newToken;
        emit UpdatedStakingToken(oldToken, newToken);
    }

    function setSupportLockPeriod(uint period, bool isSupport) external onlyOwner {
        isSupportPeriod[period] = isSupport;
        emit SetSupportedPeriod(period, isSupport);
    }

    function setPassportContract(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Invalid address");
        require(passportContract != newAddress, "Already the same contract");
        passportContract = newAddress;
        emit UpdatedPassportContract(newAddress);
    }

    function setForceUnlockingPenalty(uint newPenalty) external onlyOwner {
        require(forceUnlockingPenalty != newPenalty, "Already the same penalty");
        require(PENALTY_DENOMINATOR >= newPenalty, "Penalty should be lower than PENALTY_DENOMINATOR");
        forceUnlockingPenalty = newPenalty;
        emit UpdatedForceUnlockingPenalty(newPenalty);
    }

    function stake(uint gamerId, uint amount) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        require(amount > 0, "Invalid amount");

        UserStakingInfo memory user = usersStakingInfo[gamerId];

        user.stakedAmount += amount;
        user.updatedTime = block.timestamp;

        usersStakingInfo[gamerId] = user;
        bool success = IERC20(stakedToken).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        if (userUnstakingStatus[gamerId].isRequested) {
            userUnstakingStatus[gamerId].isRequested = false;
        }

        emit Staked(msg.sender, amount, gamerId);
    }

    function lock(uint gamerId, uint amount, uint period) external isValidPeriod(period) {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        require(amount > 0, "Invalid amount");

        UserLockInfo memory user = usersLockInfo[gamerId][period];
        require(user.lockedAmount == 0, "Already locked for the same period");

        user.lockedAmount = amount;
        user.lockedTime = block.timestamp;

        bool success = IERC20(stakedToken).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        usersLockInfo[gamerId][period] = user;

        emit Locked(msg.sender, amount, period, gamerId);
    }

    function requestUnstake(uint gamerId, bool isUnstaking) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        require(usersStakingInfo[gamerId].stakedAmount > 0, "Invalid staked amount");
        UnstakingStatus memory userStatus = userUnstakingStatus[gamerId];
        require(userStatus.isRequested != isUnstaking, "Already requested/canceled");

        userStatus.requestedTime = block.timestamp;
        userStatus.isRequested = isUnstaking;

        userUnstakingStatus[gamerId] = userStatus;
        emit RequestedUnstaking(msg.sender, isUnstaking, gamerId);
    }

    function unStake(uint gamerId) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        UserStakingInfo memory user = usersStakingInfo[gamerId];
        require(user.stakedAmount > 0, "No staked amount");
        require(userUnstakingStatus[gamerId].isRequested, "Unstaking has not been requested");
        require(block.timestamp - userUnstakingStatus[gamerId].requestedTime >= cooldownPeriod, "Cooldown period has not passed");

        delete usersStakingInfo[gamerId];

        bool success = IERC20(stakedToken).transfer(msg.sender, user.stakedAmount);
        require(success, "Transfer failed");

        emit Unstaked(msg.sender, gamerId);
    }

    function unLock(uint gamerId, uint period) external isValidPeriod(period) {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        UserLockInfo memory user = usersLockInfo[gamerId][period];
        require(user.lockedAmount > 0, "No locked amount");
        require(block.timestamp >= user.lockedTime + (period * YEAR) / 12, "Lock period is not passed");
        delete usersLockInfo[gamerId][period];

        bool success = IERC20(stakedToken).transfer(msg.sender, user.lockedAmount);
        require(success, "Transfer failed");

        emit Unlocked(msg.sender, period, gamerId);
    }

    function convertStakingToLock(uint gamerId, uint period) external isValidPeriod(period) {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        UserStakingInfo memory user = usersStakingInfo[gamerId];
        require(user.stakedAmount > 0, "No staked amount");
        delete usersStakingInfo[gamerId];
        
        UserLockInfo memory userLock = usersLockInfo[gamerId][period];

        userLock.lockedAmount += user.stakedAmount;
        userLock.lockedTime = block.timestamp;

        usersLockInfo[gamerId][period] = userLock;

        emit UpgradedLock(msg.sender, 0, period, gamerId);
    }

    function upgradeLock(uint gamerId, uint oldPeriod, uint newLockedPeriod) external isValidPeriod(newLockedPeriod) {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        require(newLockedPeriod > oldPeriod, "Only available for increasing locked period");

        UserLockInfo memory user = usersLockInfo[gamerId][oldPeriod];
        require(user.lockedAmount > 0, "No locked amount");
        delete usersLockInfo[gamerId][oldPeriod];

        UserLockInfo memory newPeriodLockInfo = usersLockInfo[gamerId][newLockedPeriod];
        newPeriodLockInfo.lockedTime = block.timestamp;
        newPeriodLockInfo.lockedAmount += user.lockedAmount;

        usersLockInfo[gamerId][newLockedPeriod] = newPeriodLockInfo;
        emit UpgradedLock(msg.sender, oldPeriod, newLockedPeriod, gamerId);
    }

    function forceUnLock(uint gamerId, uint period) external isValidPeriod(period) {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        UserLockInfo memory user = usersLockInfo[gamerId][period];
        require(user.lockedAmount > 0, "No locked amount");
        uint remainPeriod = user.lockedTime + (period * YEAR) / 12 - block.timestamp;
        delete usersLockInfo[gamerId][period];

        uint penalty = (forceUnlockingPenalty * remainPeriod) / ((period * YEAR) / 12);
        uint unLockAmount = user.lockedAmount - (user.lockedAmount * penalty) / PENALTY_DENOMINATOR;

        bool success = IERC20(stakedToken).transfer(msg.sender, unLockAmount);
        require(success, "Transfer failed");

        emit ForceUnlock(msg.sender, period, gamerId);
    }
}
