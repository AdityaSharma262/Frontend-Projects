// SPDX-License-Identifier: MIT
pragma solidity ^0.8;           

contract crowdfunding {
    mapping(address=>uint)public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipient;
        uint value ; 
        bool completed;
        uint noOfVoters;
        mapping (address=>bool)voters;
    }
    mapping (uint=>Request)public requests;
    uint public numRequests;

    constructor(uint _target,uint _deadline) {
        target= _target;
        deadline= block.timestamp + _deadline;
        minimumContribution= 100 wei;
        manager= msg.sender;
    }
    function sendEth() payable public {
        require(block.timestamp < deadline , "Deadline has passed");
        require(msg.value >=minimumContribution, "Minimum contribution not reached");
        
        if (contributors[msg.sender]==0) {
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount += msg.value;
    } 
    function GetContractBalance() public view returns(uint) {
        return address(this).balance;
    }
    function refund()public{
        require(block.timestamp > deadline && raisedAmount < target, "you are not eligible to get refund");
        require(contributors[msg.sender]>0);
        address payable user = payable (msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }
    modifier onlymanager() {
        require(msg.sender == manager, "Access Denied");
        _;}
        function createRequests(string memory _description , address payable _recipient, uint _value)public onlymanager{
            Request storage newRequest = requests[numRequests];
            numRequests++;
            newRequest.description = _description;
            newRequest.recipient = _recipient;
            newRequest.value = _value;
            newRequest.completed = false;
            newRequest.noOfVoters = 0;
        }
        function voteRequest(uint _requestNo)public{
            require(contributors[msg.sender]>0,"you're not an contributor");
            Request storage thisRequest = requests[_requestNo];
            require(thisRequest.voters[msg.sender]==false,"you have already voted");
            thisRequest.voters[msg.sender]= true;
            thisRequest.noOfVoters++;
        } 
        function makePayment(uint _requestNo)public onlymanager{
            require(raisedAmount >= target,"raised amount is not enough");
            Request storage thisRequest = requests[_requestNo];
            require(thisRequest.completed==false,"the request has been completed");
            require(thisRequest.noOfVoters >noOfContributors/2,"Majority does not support");
            thisRequest.recipient.transfer(thisRequest.value);
            thisRequest.completed = true;
        }
    
}