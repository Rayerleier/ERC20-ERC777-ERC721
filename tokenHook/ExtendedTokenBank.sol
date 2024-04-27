// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Write a TokenBank contract that can deposit your own Token into TokenBank and withdraw from TokenBank.

// TokenBank has two methods:

// deposit(): needs to record the deposit amount for each address;
// withdraw(): users can withdraw their previously deposited tokens.
// Enter your code or github link in the answer box.
interface ITokenReceiver {
    function tokensReceived(address to, uint256 amount) external returns (bool);
}

contract TokenBank is ITokenReceiver {
    mapping(address => mapping(address => uint256)) public balances;
    address admin;

    constructor() {
        admin = msg.sender;
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin, "Only Admin");
        _;
    }

    modifier OnlyContract(address account) {
        require(isContract(account), "Only Contract");
        _;
    }

    // 判断是否为合约
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // Extend TokenBank to implement deposits using the transfer callback from the previous question.
    function tokensReceived(
        address to,
        uint256 amount
    ) external OnlyContract(msg.sender) returns (bool) {
        balances[msg.sender][to] += amount;
        emit Deposited(to, amount);
        return true;
    }

    function deposit(
        address _constractAdress,
        uint256 _amount
    ) public returns (bool) {
        // 确认ERC20中存在balance
        (bool success, bytes memory data) = _constractAdress.call(
            abi.encodeWithSignature("balanceOf(address _owner)", msg.sender)
        );
        uint256 result = abi.decode(data, (uint256));
        require(result >= _amount, "Not enough balance in ERC20.");
        require(success, "Request failed.");

        // 确认ERC20中存在allowance
        (bool allowanceSuccess, bytes memory allowanceData) = _constractAdress
            .call(
                abi.encodeWithSignature(
                    "allowance(address _owner, address _spender)",
                    msg.sender,
                    this
                )
            );
        uint256 allowanceResult = abi.decode(allowanceData, (uint256));
        require(allowanceResult >= _amount, "Not enough allowance in ERC20.");
        require(allowanceSuccess, "Allowance Request failed.");

        // 从ERC20中转账
        (bool transferSuccess, ) = _constractAdress.call(
            abi.encodeWithSignature(
                "transferFrom(address _from, address _to, uint256 _value)",
                msg.sender,
                this,
                _amount
            )
        );
        require(transferSuccess, "Transfer Failed.");
        balances[_constractAdress][msg.sender] += _amount;
        emit Deposited(msg.sender, _amount);
        return transferSuccess;
    }

    function withdraw(
        address _constractAdress,
        uint256 _amount
    ) public OnlyAdmin returns (bool) {
        require(
            balances[_constractAdress][msg.sender] >= _amount,
            "Not enough balances in TokenBank"
        );
        (bool withdrawSuccess, ) = _constractAdress.call(
            abi.encodeWithSignature(
                "transfer(address _to, uint256 _value)",
                _constractAdress,
                _amount
            )
        );
        require(withdrawSuccess, "Withdraw Failed.");
        balances[_constractAdress][msg.sender] -= _amount;
        emit Withdrawn(msg.sender, _amount);
        return withdrawSuccess;
    }
}
