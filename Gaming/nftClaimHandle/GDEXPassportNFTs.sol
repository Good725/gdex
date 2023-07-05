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

contract GDEXPassportNFTs is Ownable, ERC721Holder {

    address public passportContract;
    uint public lockPeriod;

    mapping(uint => mapping(address => mapping(uint => uint))) public userNFTStakedTime;

    event UpdatedPassportContract(address indexed newAddress);
    event UpdatedLockPeriod(uint newPeriod);
    event Staked(uint gamerId, address indexed nftAddress, uint tokenId);
    event Withdrawn(uint gamerId, address indexed nftAddress, uint tokenId);
    event WithdrawnBatch(uint gamerId, address[] nftAddresses, uint[] tokenIds);

    constructor(address _passportContract, uint _lockPeriod) {
        require(_passportContract != address(0), "Invalid passport address");
        passportContract = _passportContract;
        lockPeriod = _lockPeriod;
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

    function stake(uint gamerId, address nftAddress, uint tokenId) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Caller is not owner of the NFT");

        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);

        userNFTStakedTime[gamerId][nftAddress][tokenId] = block.timestamp;
        emit Staked(gamerId, nftAddress, tokenId);
    }

    function withdraw(uint gamerId, address nftAddress, uint tokenId) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
        uint userStakedTime = userNFTStakedTime[gamerId][nftAddress][tokenId];
        require(userStakedTime > 0, "No staked this nft tokenId");
        require(block.timestamp >= userStakedTime + lockPeriod, "Lock period has not passed");

        delete userNFTStakedTime[gamerId][nftAddress][tokenId];

        IERC721(nftAddress).safeTransferFrom(address(this), msg.sender, tokenId);
        emit Withdrawn(gamerId, nftAddress, tokenId);
    }

    function withdrawBatch(uint gamerId, address[] calldata nftAddresses, uint[] calldata tokenIds) external {
        require(IERC721(passportContract).ownerOf(gamerId) == msg.sender, "Caller is not the gamer");
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
