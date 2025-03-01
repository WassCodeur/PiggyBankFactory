// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./ERC20.sol";

contract KoloBank {
    uint256 public targetDate;
    uint256 public totalSave;
    address public owner;
    address public admin;
    ERC20 token;
    address[] private tokensSaved;

    bool public hasWithdrawn = false;

    mapping(address => bool ) private isSaved;
    mapping(address => uint256 ) public totalSaves;
    mapping(address => bool ) public isSupported;
 

    error InvalidAddress();
    error UnAuthorized();
    error InsufficentAmount();
    error ThisKoloIsDestroyed(string message);
    error targetDateReached(string);
    error ArrayLengthMismatch();
    error TokenNotSppored();

  event Save(address indexed _account, string tokenSaved, uint256 _amount, uint256 savedAt);

    constructor(address _owner, address[] memory _supportedTokens, uint32 _duration) {
        owner = _owner;
        admin = msg.sender;
        targetDate = block.timestamp + (86400 * uint256(_duration));
        if ( _supportedTokens.length == 3) {
            isSupported[_supportedTokens[0]] = true;
            isSupported[_supportedTokens[1]] = true;
            isSupported[_supportedTokens[2]] = true;
        } else {
            revert ArrayLengthMismatch();
        }
    }

    modifier isNotDestroy() {
        if(hasWithdrawn == true) revert ThisKoloIsDestroyed("Kindly create a new kolo");
        _;
    }

    function save(address _owner, address _tokenAddr, uint256 _amount) public isNotDestroy {
        if (_owner != owner) revert UnAuthorized();
        if (_tokenAddr == address(0)) revert InvalidAddress();
        if(isSupported[_tokenAddr] == false) revert TokenNotSppored();
        if (ERC20(_tokenAddr).balanceOf(_owner) < _amount) revert InsufficentAmount();
        ERC20(_tokenAddr).transferFrom(_owner, address(this), _amount);
        // ERC20(_tokenAddr).transfer(address(this), _amount);

        if ( isSaved[ _tokenAddr] == false) {
            isSaved[ _tokenAddr] = true;
            tokensSaved.push(_tokenAddr);
        }
        totalSaves[_tokenAddr] += _amount;
        emit Save(msg.sender, ERC20(_tokenAddr).name(),  _amount, block.timestamp);
        
    }
    function SaveMultiple(address _owner, address[] calldata _tokenAddrs, uint256[] calldata _amounts) public isNotDestroy{
        if (_owner != owner) revert UnAuthorized();
        if(_amounts.length != _tokenAddrs.length || _tokenAddrs.length  > 3 || _amounts.length > 3 ) revert ArrayLengthMismatch();
        
        for (uint i = 0; i < _amounts.length; i++) {
            if (_tokenAddrs[i] == address(0)) revert InvalidAddress();
            if(isSupported[_tokenAddrs[i]] == false) revert TokenNotSppored();
            if (ERC20(_tokenAddrs[i]).balanceOf(_owner) < _amounts[i]) revert InsufficentAmount();
            ERC20(_tokenAddrs[i]).transferFrom(_owner, address(this), _amounts[i]);
            if ( isSaved[ _tokenAddrs[i]] == false) {
            isSaved[ _tokenAddrs[i]] = true;
            tokensSaved.push(_tokenAddrs[i]);
            }
            totalSaves[_tokenAddrs[i]] += _amounts[i];
        
            emit Save(msg.sender, ERC20(_tokenAddrs[i]).name(),  _amounts[i], block.timestamp);
        }
    }

    function withdraw(address _owner) public {
        if (_owner == address(0)) revert InvalidAddress();
        if (_owner != owner) revert UnAuthorized();
        for (uint i = 0; i < tokensSaved.length; i++) {
            uint256 _tokenamout = totalSaves[tokensSaved[i]];
            if (targetDate > block.timestamp ) {
                uint256 _penaltyAmount = (_tokenamout * 15) / 100;
                _tokenamout = _tokenamout - _penaltyAmount ;
                ERC20(tokensSaved[i]).transfer(admin, _penaltyAmount);
            }
            ERC20(tokensSaved[i]).transfer(_owner, _tokenamout);

        }
    hasWithdrawn= true;     
    }

    function withdrawOneToken(address _tokenAddr) public {}
}
