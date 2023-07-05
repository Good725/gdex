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

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GDEXGuild is 
    Context,
    AccessControlEnumerable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable 
{
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    Counters.Counter private _tokenIdTracker;
    string public baseTokenURI;

    event UpdatedBaseURI(string newURI);
    
    event MintGuildNFT(uint tokenId, address from, address to, string roleId);

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory _baseTokenURI
    ) ERC721(name, symbol) {
        baseTokenURI = _baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     */
    function mint(address to, string memory roleId) external virtual {
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
        emit MintGuildNFT(_tokenIdTracker.current(), msg.sender, to, roleId);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() external virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() external virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory newURI) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have admin role to set");
        baseTokenURI = newURI;
        emit UpdatedBaseURI(newURI);
    }
}
