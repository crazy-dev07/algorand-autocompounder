// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4; // Using compiler >0.8.4 to increase efficiency and reduce gas costs

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract AlgorandYieldOptimizer {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address owner;
    mapping (address => mapping (string => uint)) public balances;
    mapping (string => uint) public interest;
    uint public totalSupply;
    uint public interest;
    
    // constructor
    constructor() {
        owner = msg.sender;
        totalSupply = 0;
        interest = 0;
    }
    
    // Deposit tokens
    function deposit(string memory _token) public payable  {
        require(msg.value > 0, "Amount must be greater than 0");
        balances[msg.sender][_token] += msg.value;
        interest += msg.value;
        emit Deposit(msg.sender, msg.value, _token);
    }
    
    // Withdraw tokens
    function withdraw(string memory _token, uint _amount) public {
        require(balances[msg.sender][_token] >= _amount, "Insufficient balance");
        balances[msg.sender][_token] -= _amount;
        interest -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdrawal(msg.sender, _amount, _token);
    }
    
    // Compound interest on user's balance
    function compoundInterest(string memory _token) public {
        require(interest[_token] > 0, "Interest rate for the token is not set");
        uint interestAmount = balances[msg.sender][_token] * interest[_token] / 100;
        balances[msg.sender][_token] += interestAmount;
        interest += interestAmount;
        emit InterestCompounded(msg.sender, interestAmount, _token);
    }
    
    // Update interest rate for a token
    function updateInterestRate(string memory _token, uint _rate) public {
        require(msg.sender == owner, "Only the contract owner can update interest rate");
        interest[_token] = _rate;
        emit InterestUpdated(_token, _rate);
    }
    
    // Add a new token
    function addToken(string memory _token) public {
        require(msg.sender == owner, "Only the contract owner can add a new token");
        interest[_token] = 0;
        emit TokenAdded(_token);
    }
    
    // Remove a token
    function removeToken(string memory _token) public {
        require(msg.sender == owner, "Only the contract owner can remove a token");
        require(interest[_token] > 0, "Token does not exist in the contract");
        delete interest[_token];
        emit TokenRemoved(_token);
    }
    
    // Events
    event Deposit(address indexed _user, uint _amount, string _token);
    event Withdrawal(address indexed _user, uint _amount, string _token);
    event InterestCompounded(address indexed _user, uint _amount, string _token);
    event InterestUpdated(string _token, uint _rate);
    event TokenAdded(string _token);
    event TokenRemoved(string _token);
}
