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

contract GDEXPassportFTs is Ownable {

    address public passportContract;
    uint public lockPeriod;

    struct StakedInfo {
        uint amount;
        uint stakedTime;
    }

    mapping(uint => mapping(address => StakedInfo)) public userStakedInfo;

    event UpdatedPassportContract(address indexed newAddress);
    event UpdatedLockPeriod(uint newPeriod);
    event Staked(uint gamerId, address indexed tokenAddress, uint amount);
    event Withdrawn(uint gamerId, address indexed tokenAddress, uint amount);
    event WithdrawnBatch(uint gamerId, address[] tokenAddresses, uint[] amounts);

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

    function stake(uint gamerId, address tokenAddress, uint amount) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddress];

        userInfo.amount += amount;
        userInfo.stakedTime = block.timestamp;

        userStakedInfo[gamerId][tokenAddress] = userInfo;

        emit Staked(gamerId, tokenAddress, amount);
    }

    function withdraw(uint gamerId, address tokenAddress, uint amount) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");

        StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddress];
        require(userInfo.amount >= amount, "Insufficient staked amount");
        require(block.timestamp >= userInfo.stakedTime + lockPeriod, "Lock period has not passed");

        if (userInfo.amount == amount) {
            delete userStakedInfo[gamerId][tokenAddress];
        } else {
            userInfo.amount = userInfo.amount - amount;
            userStakedInfo[gamerId][tokenAddress] = userInfo;
        }

        IERC20(tokenAddress).transfer(msg.sender, amount);

        emit Withdrawn(gamerId, tokenAddress, amount);
    }

    function withdrawBatch(uint gamerId, address[] calldata tokenAddresses, uint[] calldata amounts) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        require(tokenAddresses.length == amounts.length, "Must be the same length");

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddresses[i]];
            require(userInfo.amount >= amounts[i], "Insufficient staked amount");
            require(block.timestamp >= userInfo.stakedTime + lockPeriod, "Lock period has not passed");

            if (userInfo.amount == amounts[i]) {
                delete userStakedInfo[gamerId][tokenAddresses[i]];
            } else {
                userInfo.amount = userInfo.amount - amounts[i];
                userStakedInfo[gamerId][tokenAddresses[i]] = userInfo;
            }

            IERC20(tokenAddresses[i]).transfer(msg.sender, amounts[i]);
        }

        emit WithdrawnBatch(gamerId, tokenAddresses, amounts);
    }
}
