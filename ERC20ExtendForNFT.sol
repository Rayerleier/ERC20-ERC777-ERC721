// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// interface IERC20 {
//     function balanceOf(address _owner) external  view returns (uint256 balance);
//     function transfer(address _to, uint256 _value) external  returns (bool success);
//     function transferFrom(address _from, address _to, uint256 _value) external  payable returns (bool success);
//     function approve(address _spender, uint256 _value) external  returns (bool success);
//     function allowance(address _owner, address _spender) external  view returns (uint256 remaining);
// }


import "ExtendedNFTMarket.sol";

abstract contract MyERC20  {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    ITokenReceiver NFTcontract;

    constructor(address NFTmarket)  {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10 ** uint256(decimals); 
        balances[msg.sender] = totalSupply;
        NFTcontract = ITokenReceiver(NFTmarket);
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
        uint256 tokenId
    ) internal {
       
        NFTcontract.tokensReceived(from, to, amount, tokenId);
        
    }

    // 扩展回调函数, 购买指定NFT
    function transferExtended(address _to,  uint256 tokenId) public returns (bool success) {
        uint256 price = NFTcontract.queryPrice(tokenId);
        require(price<= balances[msg.sender], "Not enough balance for NFT");
        balances[msg.sender] -= price;
        _afterTokenTransfer(msg.sender, _to, price, tokenId);
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