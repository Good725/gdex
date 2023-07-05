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

contract GDEXPassportNFTs_1155 is Ownable, ERC1155Holder {

    address public passportContract;
    uint public lockPeriod;

    struct StakedInfo {
        uint amount;
        uint stakedTime;
    }

    mapping(uint => mapping(address => mapping(uint => StakedInfo))) public userStakedInfo;

    event UpdatedPassportContract(address indexed newAddress);
    event UpdatedLockPeriod(uint newPeriod);
    event Staked(uint gamerId, address indexed tokenAddress, uint tokenId, uint amount);
    event Withdrawn(uint gamerId, address indexed tokenAddress, uint tokenId, uint amount);
    event WithdrawnBatch(uint gamerId, address[] tokenAddresses, uint[] tokenIds, uint[] amounts);

    constructor(address _passportContract) {
        require(_passportContract != address(0), "Invalid passport address");
        passportContract = _passportContract;
    }

    function setLockPeriod(uint newPeriod) external onlyOwner {
        require(lockPeriod != newPeriod, "Already the same period");
        lockPeriod = newPeriod;

        emit UpdatedLockPeriod(newPeriod);
    }

    function setPassportContract(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Invalid address");
        require(passportContract != newAddress, "Already the same contract");
        passportContract = newAddress;

        emit UpdatedPassportContract(newAddress);
    }

    function stake(uint gamerId, address tokenAddress, uint tokenId, uint amount) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");

        IERC1155(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddress][tokenId];

        userInfo.amount += amount;
        userInfo.stakedTime = block.timestamp;

        userStakedInfo[gamerId][tokenAddress][tokenId] = userInfo;

        emit Staked(gamerId, tokenAddress, tokenId, amount);
    }

    function withdraw(uint gamerId, address tokenAddress, uint tokenId, uint amount) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");

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
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
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