//SPDX-License-Identifier: MIT

pragma solidity ^0.8;
contract StakingRewards {
    IERC20 public rewardsToken;  //rewardToken variable of type IERC20 for reward token.
    IERC20 public stakingToken;  //stakingToken variable of type IERC20 declared for for staking token.

    uint public rewardRate = 100; //used in calculating rewards.
    uint public lastUpdateTime; //to store the timestamp value of block when stacking token.
    uint public rewardPerTokenStored; //to store the rewards per token.

    // MAPPINGS
    mapping(address=>uint) public userRewardPerTokenPaid; //mapping of users address to rewards paid.
    mapping(address=>uint) public rewards; //mapping of users address to earned rewards.
    mapping(address=>uint) private _balances; //mapping of users address to tokens staked.

    uint private _totalSupply; //to store the total supply of the rewarding tokens.

    // CONSTRUCTOR
    //takes two arguments, staking token address and rewards token address.
    constructor(address _stakingToken, address _rewardsToken) payable{
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    // MODIFIER

    // this modifier is used to update the rewards per token and timestamp. Also updates rewards and userRewardPerTokenPaid mapping.
    // it takes address as an argument.
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    // Functions

    //this function is a utility function. it calculates the rewardsPerToken based on a formula. (timestamp, rewardsrate and totalsupply)
    //returns the calculated rewards based on above parameters.
    function rewardPerToken() public view returns(uint) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
    }

    // this function is used to calculate the earned rewards for a perticular users address account. it fetches the data from the mapping and uses a formula to calculate the profits.
    // it returns the profit earnings based on a formula.
    function earned(address account) public view returns(uint) {
        return ((_balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) + rewards[account];
    }

    // this function is  used to stake the amount of tokens and will call the modifier to update various parameters.
    // _balance mapping is updated and the tokens are transfered from users account to smart contract
    function stake(uint _amount) external updateReward(msg.sender) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    // this function is used to withdraw the staked token and will call the modifier to update various parameters.
    // _balance mapping is updated and the tokens are transfered from smart contract to users account.
    function withdraw(uint _amount) external updateReward(msg.sender) {
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;       
        stakingToken.transfer(msg.sender, _amount);
    }

    // this function is used to claim the rewards that are earned by staking the tokens. updateReward modifier is called to update various parameter.
    // rewards mapping is called to update the rewards for the caller to 0 and then rewards tokens are transfered to users account.
    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
    }
}

interface IERC20 {
    function totalSupply() external view returns(uint);
    function balanceOf(address account) external view returns(uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns(uint);
    function approve(address spender, uint amount) external returns(bool);
    function transferFrom(address spender, address recipient, uint amount) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}