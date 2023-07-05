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
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract GDEXPassportNFTs_bsc is Ownable, ERC721Holder {

    uint public lockPeriod;

    mapping(address => mapping(uint => bool)) private _requestedDeposit;
    mapping(address => mapping(uint => bool)) private _allowedDeposit;
    mapping(address => mapping(uint => bool)) private _requestedWithdraw;
    mapping(address => mapping(uint => bool)) private _allowedWithdraw;
    mapping(uint => mapping(address => mapping(uint => uint))) public userNFTStakedTime;

    event UpdatedLockPeriod(uint newPeriod);
    event RequestedDeposit(address indexed user, uint gamerId, uint time);
    event AllowedDeposit(address indexed user, uint gamerId);
    event RequestedWithdraw(address indexed user, uint gamerId, uint time);
    event AllowedWithdraw(address indexed user, uint gamerId);
    event Staked(uint gamerId, address indexed nftAddress, uint tokenId);
    event Withdrawn(uint gamerId, address indexed nftAddress, uint tokenId);
    event WithdrawnBatch(uint gamerId, address[] nftAddresses, uint[] tokenIds);

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

    function stake(uint gamerId, address nftAddress, uint tokenId) external {
        require(_allowedDeposit[msg.sender][gamerId], "Not allowed to stake");
        _allowedDeposit[msg.sender][gamerId] = false;
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Caller is not owner of the NFT");

        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);

        userNFTStakedTime[gamerId][nftAddress][tokenId] = block.timestamp;
        emit Staked(gamerId, nftAddress, tokenId);
    }

    function withdraw(uint gamerId, address nftAddress, uint tokenId) external {
        require(_allowedWithdraw[msg.sender][gamerId], "Not allowed to withdraw");
        _allowedWithdraw[msg.sender][gamerId] = false;

        uint userStakedTime = userNFTStakedTime[gamerId][nftAddress][tokenId];
        require(userStakedTime > 0, "No staked this nft tokenId");
        require(block.timestamp >= userStakedTime + lockPeriod, "Lock period has not passed");

        delete userNFTStakedTime[gamerId][nftAddress][tokenId];

        IERC721(nftAddress).safeTransferFrom(address(this), msg.sender, tokenId);
        emit Withdrawn(gamerId, nftAddress, tokenId);
    }

    function withdrawBatch(uint gamerId, address[] calldata nftAddresses, uint[] calldata tokenIds) external {
        require(_allowedWithdraw[msg.sender][gamerId], "Not allowed to withdraw");
        _allowedWithdraw[msg.sender][gamerId] = false;

        require(nftAddresses.length == tokenIds.length, "Must be the same length");

        for (uint256 i = 0; i < nftAddresses.length; i++) {
            uint userStakedTime = userNFTStakedTime[gamerId][nftAddresses[i]][tokenIds[i]];
            require(userStakedTime > 0, "No staked this nft tokenId");
            require(block.timestamp >= userStakedTime + lockPeriod, "Lock period has not passed");

            delete userNFTStakedTime[gamerId][nftAddresses[i]][tokenIds[i]];

            IERC721(nftAddresses[i]).safeTransferFrom(address(this), msg.sender, tokenIds[i]);
        }

        emit WithdrawnBatch(gamerId, nftAddresses, tokenIds);
    }
}
