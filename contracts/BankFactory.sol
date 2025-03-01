// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.28;

import "./KoloBank.sol";

contract BankFactory {
    address[] public authorizedTokens;
    address public owner;
    mapping(address => address[]) public koloBanks;

    error InvalidAddress();
    error UnAuthorized();
    error transactionFailed(string message);
    error ArrayLengthMismatch();

    constructor(address[] memory _authorizedTokens) {
        authorizedTokens = _authorizedTokens;
        owner = msg.sender;
    }

    function GetKoloBankBytecode(
        address _owner,
        address[] memory _supportedTokens,
        uint32 _duration
    ) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                type(KoloBank).creationCode,
                abi.encode(_owner, _supportedTokens, _duration)
            );
    }

    function getKolo(address user) public view returns (address[] memory) {
        return koloBanks[user];
    }

    function createKoloBank(uint32 _duration) public returns (address contractAddr) {
        if (msg.sender == address(0)) revert InvalidAddress();

        bytes memory _bytecode = GetKoloBankBytecode(
            msg.sender,
            authorizedTokens,
            _duration
        );
        bytes32 _salt = keccak256(
            abi.encodePacked(msg.sender, koloBanks[msg.sender].length)
        );
        bytes32 _hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(_bytecode)
            )
        );
        address deployedAddress = address(uint160(uint256(_hash)));
        contractAddr = deployedAddress;
        assembly {
            deployedAddress := create2(
                0,
                add(_bytecode, 0x20),
                mload(_bytecode),
                _salt
            )
        }
        koloBanks[msg.sender].push(deployedAddress);


    }

 

    function save(
        address _tokenAddr,
        address _contractAddress,
        uint256 _amount
    ) public returns (bool) {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_tokenAddr == address(0)) revert InvalidAddress();
        if (_contractAddress == address(0)) revert InvalidAddress();
        for (uint i = 0; i < koloBanks[msg.sender].length; i++) {
            if (_contractAddress == koloBanks[msg.sender][i]) {
                KoloBank(koloBanks[msg.sender][i]).save(
                    msg.sender,
                    _tokenAddr,
                    _amount
                );
                return true;
            }
        }
        revert transactionFailed("save failed");
    }

    function withdraw(address _contractAddress) public returns (bool) {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_contractAddress == address(0)) revert InvalidAddress();
        for (uint i = 0; i < koloBanks[msg.sender].length; i++) {
            if (_contractAddress == koloBanks[msg.sender][i]) {
                KoloBank(koloBanks[msg.sender][i]).withdraw(msg.sender);
                return true;
            }
        }
        revert transactionFailed("withdraw failed");
    }

    function SaveMultiple(
        address _contractAddress,
        address[] calldata _tokenAddrs,
        uint256[] calldata _amounts
    ) public returns (bool) {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_contractAddress == address(0)) revert InvalidAddress();
        if (
            _amounts.length != _tokenAddrs.length ||
            _tokenAddrs.length > 3 ||
            _amounts.length > 3
        ) revert ArrayLengthMismatch();
        for (uint i = 0; i < koloBanks[msg.sender].length; i++) {
            if (_contractAddress == koloBanks[msg.sender][i]) {
                KoloBank(koloBanks[msg.sender][i]).SaveMultiple(
                    msg.sender,
                    _tokenAddrs,
                    _amounts
                );
                return true;
            }
        }
        revert transactionFailed("saves failed");
    }
}
