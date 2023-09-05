//SPDX-License-Identifier: MIT
pragma solidity 0.8;


interface PrimeToken {
    function balanceOf(address amount)external returns(uint);
 function transferFrom(address _from,address _to, uint)external returns(bool);
 function transfer (address to,uint amount)external returns (bool);

}

contract RewardStaking{
    PrimeToken  primetoken;

    struct Stake{
        uint Stakeamount;
        uint Staketime;
        uint Totalreward;

    }
    mapping(address => Stake)stakeBalance;

    constructor(address _primetoken){
        primetoken = PrimeToken(_primetoken);
    }
    uint private constant OneSecond = 60;
    event Tokenstake(address staker, uint amount);
    event TokenReward(address staker, uint amount);

    modifier Tokenowner(){
        uint primetokenbalance = primetoken.balanceOf(msg.sender);
        require(primetokenbalance > 0,"you do not have primetoken");
        _;


    }
    function getstakedetail(address _stakebalance)public returns(Stake memory _stake ){
        calculateAccuredReward();
        _stake = stakeBalance[_stakebalance];
    }

    function stake1(uint amount)external Tokenowner{
        Stake storage _stake = stakeBalance[msg.sender];
        require(amount > 0,"staking amount must be greater than zero");
        bool success = _transferFrom(amount);
        if(success){
            if(_stake.Stakeamount == 0){
                _stake.Staketime = block.timestamp;
                _stake.Stakeamount = amount;
            }
        
            else {
                _stake.Stakeamount += amount;
                //calcaulate accured reward
                calculateAccuredReward();
            }
            emit Tokenstake(msg.sender, amount);
        }

            else {
                revert ("stake failed");
            }


        }

    
    function claimreward()external returns(bool success){
        Stake storage _stake = stakeBalance[msg.sender];
        require(_stake.Totalreward < primetoken.balanceOf(address(this)),
        "add fund");
        calculateAccuredReward();
        require(_stake.Totalreward > 0,"no reward");

        _stake.Totalreward = 0;
        _stake.Stakeamount= 0;
        _stake.Staketime = 0;
        primetoken.transfer(msg.sender,_stake.Totalreward);
        primetoken.transfer(msg.sender,_stake.Stakeamount);
        emit TokenReward(msg.sender, _stake.Totalreward);
        return success = true;



    }
    function _transferFrom(uint amount) internal returns (bool success) {
        success = primetoken.transferFrom(msg.sender, address(this), amount);
        return (success);
    }
            //formula to calculate your reward of 5% of staked token and then returns the percent in reward tokens after one week
    function calculateAccuredReward() internal {
        Stake storage _stake = stakeBalance[msg.sender];
        uint difference = block.timestamp - _stake.Staketime;
        _stake.Totalreward = (difference * _stake.Stakeamount * 5) /(OneSecond * 100);
    }





}

