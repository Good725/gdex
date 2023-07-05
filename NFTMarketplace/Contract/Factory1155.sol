//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "./GdexNFTUser1155Token.sol";

contract Factory1155 {
    event Deployed(address owner, address contractAddress);

    function deploy(
        bytes32 _salt,
        string memory name,
        string memory symbol,
        string memory tokenURIPrefix
    ) external returns (address addr) {
        addr = address(
            new GdexNFTUser1155Token{salt: _salt}(name, symbol, tokenURIPrefix)
        );
        GdexNFTUser1155Token token = GdexNFTUser1155Token(address(addr));
        token.transferOwnership(msg.sender);
        emit Deployed(msg.sender, addr);
    }
}