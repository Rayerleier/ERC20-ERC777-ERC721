// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "ExtendedNFTMarket.sol";


abstract contract MyExtendedERC20  {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor()  {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10 ** uint256(decimals); 
        balances[msg.sender] = totalSupply;

    }

    // 判断是否为合约
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    // 每次转账后调用
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount,
        bytes memory userData
    ) internal {
        if (isContract(to)) {
            ITokenReceiver(to).tokensReceived(from, to, amount,userData);
        }
    }



    // 扩展回调函数的转账
    function transferExtended(address _to, uint256 _value, bytes memory userData) public returns (bool success) {
        require(balances[msg.sender]>= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        _afterTokenTransfer(msg.sender, _to, _value, userData);
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }



    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender]>= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;   
    }

    function transferFrom(address _from, address _to, uint256 _value) public payable returns (bool success) {
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        require(balances[_from]>= _value, "ERC20: transfer amount exceeds balance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }


    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {  
        return allowances[_owner][_spender];
    }


}