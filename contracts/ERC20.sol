// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ERC20 {
    string public name;
    string public symbol;
    uint256 public totalSupply;

    uint8 public decimals;
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    error InvalidAddress();
    error InsufficentAmount();
    error InsufficentAllowance();
    error  InsufficentBalance();
    error YourAreNotAllowToCallThisFunction();

    event Transfer(address indexed _from, address _to, uint256 _amount);
    event Approval(address indexed owner, address _spender, uint256 _amount);

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert YourAreNotAllowToCallThisFunction();
        }
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals  = _decimals;
        totalSupply = _initialSupply * 10** uint256(decimals);
        balances[owner] += totalSupply;
    }

    function mint(address _account, uint256 _amount) external onlyOwner {
        if (_account == address(0)) revert InvalidAddress();
        balances[_account] += _amount;
        totalSupply += _amount;
        emit Transfer(owner, _account, _amount);
    }

    function transfer(
        address _to,
        uint256 _amount
    ) external returns (bool success) {
        if (_to == address(0)) revert InvalidAddress();
        if (balances[msg.sender] < _amount) revert InsufficentAmount();
        balances[_to] += _amount;
        balances[msg.sender] -= _amount;

        emit Transfer(msg.sender, _to, _amount);
        success = true;
    }

    function approve(
        address _spender,
        uint256 _amount
    ) external returns (bool success) {
        if (_spender == address(0)) revert InvalidAddress();
        if (balances[msg.sender] < _amount) revert InsufficentBalance();
        allowances[msg.sender][_spender] += _amount;
        emit Approval(msg.sender, _spender, _amount);
        success = true;
    }

    function balanceOf(
        address _account
    ) external view returns (uint256 balance) {
        if (_account == address(0)) revert InvalidAddress();
        balance = balances[_account];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool success) {
        if (_from == address(0)) revert InvalidAddress();
        if (_to == address(0)) revert InvalidAddress();
        if (_amount <= allowances[_from][msg.sender]) {
            balances[_to] += _amount;
            balances[_from] -= _amount;
            allowances[_from][msg.sender] -= _amount;

            emit Transfer(_from, _to, _amount);
            success = true;
        } else {
            revert InsufficentAllowance();
        }
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        if (_owner == address(0)) revert InvalidAddress();
        if (_spender == address(0)) revert InvalidAddress();
        remaining = allowances[_owner][_spender];
    }
}