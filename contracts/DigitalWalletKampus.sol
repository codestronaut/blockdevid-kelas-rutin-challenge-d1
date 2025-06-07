// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DigitalWalletKampus {
    mapping(address => uint256) public balances;
    mapping(address => bool) public student;
    address public wallet;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    
    constructor() {
        wallet = msg.sender;
    }

    modifier onlyStudent() {
        require(student[msg.sender], "Student only privilege.");
        _;
    }
    
    function deposit() public payable {
        require(msg.value > 0, "Amount must be greater than 0");

        student[msg.sender] = true;
        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }
    
    function withdraw(uint256 _amount) public payable onlyStudent {
        require(_amount > 0, "Amount must be greater than 0");

        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transaction (withdraw) failed.");

        emit Withdrawal(msg.sender, msg.value);
    }

    function transfer(address _student, uint256 _amount) public payable onlyStudent {
        require(_amount > 0, "Amount must be greater than 0");

        balances[_student] += _amount;
        balances[msg.sender] -= _amount;
        (bool success, ) = _student.call{value: _amount}("");
        require(success, "Transaction (transfer) failed.");

        emit Transfer(msg.sender, _student, msg.value);
    }

    function checkBalance() public view returns(uint256) {
        return balances[msg.sender];
    }
}