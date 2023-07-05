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
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract GDEXPassportNFTs_1155_bsc is Ownable, ERC1155Holder {

    uint public lockPeriod;

    struct StakedInfo {
        uint amount;
        uint stakedTime;
    }

    mapping(address => mapping(uint => bool)) private _requestedDeposit;
    mapping(address => mapping(uint => bool)) private _allowedDeposit;
    mapping(address => mapping(uint => bool)) private _requestedWithdraw;
    mapping(address => mapping(uint => bool)) private _allowedWithdraw;
    mapping(uint => mapping(address => mapping(uint => StakedInfo))) public userStakedInfo;

    event UpdatedLockPeriod(uint newPeriod);
    event RequestedDeposit(address indexed user, uint gamerId, uint time);
    event AllowedDeposit(address indexed user, uint gamerId);
    event RequestedWithdraw(address indexed user, uint gamerId, uint time);
    event AllowedWithdraw(address indexed user, uint gamerId);
    event Staked(uint gamerId, address indexed tokenAddress, uint tokenId, uint amount);
    event Withdrawn(uint gamerId, address indexed tokenAddress, uint tokenId, uint amount);
    event WithdrawnBatch(uint gamerId, address[] tokenAddresses, uint[] tokenIds, uint[] amounts);

    constructor() {}

    function setLockPeriod(uint newPeriod) external onlyOwner {
        require(lockPeriod != newPeriod, "Already the same period");
        lockPeriod = newPeriod;

        emit UpdatedLockPeriod(newPeriod);
    }

    function requestDeposit(uint gamerId) external {
        require(!_requestedDeposit[msg.sender][gamerId], "Already requested");
        _requestedDeposit[msg.sender][gamerId] = true;

        emit RequestedDeposit(msg.sender, gamerId, block.timestamp);
    }

    function requestWithdraw(uint gamerId) external {
        require(!_requestedWithdraw[msg.sender][gamerId], "Already requested");
        _requestedWithdraw[msg.sender][gamerId] = true;

        emit RequestedWithdraw(msg.sender, gamerId, block.timestamp);
    }

    function allowDeposit(address user, uint gamerId, bool isAllow) external onlyOwner {
        require(_requestedDeposit[user][gamerId], "The user has not requested yet");

        _allowedDeposit[user][gamerId] = isAllow;
        _requestedDeposit[user][gamerId] = false;

        emit AllowedDeposit(user, gamerId);
    }

    function allowWithdraw(address user, uint gamerId, bool isAllow) external onlyOwner {
        require(_requestedWithdraw[user][gamerId], "The user has not requested yet");

        _allowedWithdraw[user][gamerId] = isAllow;
        _requestedWithdraw[user][gamerId] = false;

        emit AllowedWithdraw(user, gamerId);
    }

    function stake(uint gamerId, address tokenAddress, uint tokenId, uint amount) external {
        require(_allowedDeposit[msg.sender][gamerId], "Not allowed to stake");
        _allowedDeposit[msg.sender][gamerId] = false;

        IERC1155(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddress][tokenId];

        userInfo.amount += amount;
        userInfo.stakedTime = block.timestamp;

        userStakedInfo[gamerId][tokenAddress][tokenId] = userInfo;

        emit Staked(gamerId, tokenAddress, tokenId, amount);
    }

    function withdraw(uint gamerId, address tokenAddress, uint tokenId, uint amount) external {
        require(_allowedWithdraw[msg.sender][gamerId], "Not allowed to withdraw");
        _allowedWithdraw[msg.sender][gamerId] = false;

        StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddress][tokenId];
        require(userInfo.amount >= amount, "Insufficient staked amount");
        require(block.timestamp >= userInfo.stakedTime + lockPeriod, "Lock period has not passed");

        if (userInfo.amount == amount) {
            delete userStakedInfo[gamerId][tokenAddress][tokenId];
        } else {
            userInfo.amount = userInfo.amount - amount;
            userStakedInfo[gamerId][tokenAddress][tokenId] = userInfo;
        }

        IERC1155(tokenAddress).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");

        emit Withdrawn(gamerId, tokenAddress, tokenId, amount);
    }

    function withdrawBatch(uint gamerId, address[] calldata tokenAddresses, uint[] calldata tokenIds, uint[] calldata amounts) external {
        require(_allowedWithdraw[msg.sender][gamerId], "Not allowed to withdraw");
        _allowedWithdraw[msg.sender][gamerId] = false;
        
        require(tokenAddresses.length == amounts.length, "Must be the same length");
        require(tokenAddresses.length == tokenIds.length, "Must be the same length");

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddresses[i]][tokenIds[i]];
            require(userInfo.amount >= amounts[i], "Insufficient staked amount");
            require(block.timestamp >= userInfo.stakedTime + lockPeriod, "Lock period has not passed");

            if (userInfo.amount == amounts[i]) {
                delete userStakedInfo[gamerId][tokenAddresses[i]][tokenIds[i]];
            } else {
                userInfo.amount = userInfo.amount - amounts[i];
                userStakedInfo[gamerId][tokenAddresses[i]][tokenIds[i]] = userInfo;
            }

            IERC1155(tokenAddresses[i]).safeTransferFrom(address(this), msg.sender, tokenIds[i], amounts[i], "");
        }

        emit WithdrawnBatch(gamerId, tokenAddresses, tokenIds, amounts);
    }
}
