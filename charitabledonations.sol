//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract CharitableDonation {

    // Struct to hold charitable donors

    struct Donor {
        string name;
        uint amount;
    }

    // Struct for each charity that can receive donations

    struct Charity {
        address payable charityAddr;
        string name;
        uint donationsAccumulated;
        uint targetAmount;
        // a mapping of an individual donor address to a Donor struct which tracks their donation
        mapping(address=>Donor) donors;
    }

    // The charity
    Charity public charity;

    address public administrator;

    // Constructor

    constructor(address payable charityAddress,  string memory charityName) {
        administrator = msg.sender;
        charity.charityAddr = charityAddress;        
        charity.name = charityName;        
    }

    // set the donation target amount
    function setTargetAmount(uint _targetAmount) public {
        require(msg.sender == administrator, "Only the administrator can set the donation target amount!");
        charity.targetAmount = _targetAmount;
    }


	// If you choose to do this assignment, write the following functions:
   // 1. A function to allow for a donor to make a donation, and track the accumulated donations;
   
    //Function to track the donation event.
	
    event DonationEvent(address indexed _donorAddress, uint indexed _donatedAmount);
	
    function donation(string memory _donorName, uint256 _donatedAmount) external payable{

        Donor memory currentDonor;

        address donorAddress = msg.sender;
	    currentDonor.name = _donorName;
	    currentDonor.amount = _donatedAmount;
	
	    charity.donors[msg.sender] = currentDonor;
        charity.donationsAccumulated += _donatedAmount;

        emit DonationEvent(donorAddress, _donatedAmount);      
    }

	// 2. A function to check if the target amount has been reached, and then releases the funds
   //    from the contract to the charity.
   
    event FundReleaseEvent(uint indexed _donatedAmount);

    function releaseFunds() public{
        require(msg.sender == administrator,"Not an admin, only admin can perform this function!");
        require(charity.donationsAccumulated >= charity.targetAmount,"Targeted amount not met!");
        (bool sent, ) = charity.charityAddr.call{value: address(this).balance}("");
        require(sent, "Transaction Error");
        emit FundReleaseEvent(charity.donationsAccumulated);
        charity.donationsAccumulated = 0;
    }
    
}