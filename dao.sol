// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract demo{

    struct Proposal{
        uint id;
        string description;
        uint amount;
        address payable  receipent;// in this address we will receive ether
        uint votes;
        uint end; //voting time kab end hoga
        bool isExecuted;
    }

    mapping (address=> bool) public isInvestor;
    mapping (address=>uint) public noOfShares; //1wei=1 no of shares
    mapping (address=>mapping (uint=>bool)) public  isVoted;
    mapping (uint=>Proposal) public proposals;
    address [] public investorsList;

    uint public  totalShares;
    uint public  avaialableFunds; //main when investor keep it then it increases and withdraw it decreases like a bank account
    uint public  contributionTimeEnd;
    uint public nextProposalId;
    uint public quorum;
    uint public voteTime; //kitne time tak voting hogi
    //in blockchain bitcoin 51% is qorom
    address public manager;// minimum no of people require to pass the proposal=> byzantine me 66%is min


    constructor(uint _contributionTimeEnd, uint _voteTime, uint _quorum)
    {
        require(_quorum>0 && _quorum<=100,"not valid values");
        contributionTimeEnd=block.timestamp+_contributionTimeEnd;
        voteTime=_voteTime;
        _quorum=quorum;
        manager=msg.sender;

    }

    modifier onlyInvestor(){
        require(isInvestor[msg.sender]==true,"You are not a investor");
        _;
    }

    modifier onlyManager(){
        require(manager==msg.sender,"You are not a manager");
        _;
    }

    function contribution() public payable  {
        require(contributionTimeEnd>block.timestamp,"Contribution time ended");
        require(msg.value>0,"send value more than zero");
        isInvestor[msg.sender]=true; // jo v contribute krega and he becomes investor afert satisfying all the condition
        noOfShares[msg.sender]=noOfShares[msg.sender]+msg.value;
        totalShares=totalShares+msg.value;
        avaialableFunds=avaialableFunds+msg.value;
        investorsList.push(msg.sender);

    }
    //investor will fetch shares
    function redeemShare(uint amount) public   onlyInvestor{
        require(noOfShares[msg.sender]>=amount,"you dont have enough shares");
        require(avaialableFunds>amount,"not enough funds");
        noOfShares[msg.sender]-=amount;
        if(noOfShares[msg.sender]==0){
            isInvestor[msg.sender]=false;
        }
        avaialableFunds-=amount;
        payable (msg.sender).transfer(amount);

    }
//investor  address shares will transferrd 'to' address
    function transferShare(uint amount,address to) public onlyInvestor{
        require(noOfShares[msg.sender]>=amount,"you dont have enough shares");
        require(avaialableFunds>amount,"not enough funds");
        noOfShares[msg.sender]-=amount;
        if(noOfShares[msg.sender]==0){
            isInvestor[msg.sender]=false;
        }
        noOfShares[to]+=amount;
        isInvestor[to]=true;
        investorsList.push(to);


    }

function createProposal(string calldata description,uint amount,address payable receipent) public onlyManager {
    require(avaialableFunds>=amount,"not enough funds");
    proposals[nextProposalId]=Proposal(nextProposalId,description,amount,receipent,0,block.timestamp+voteTime,false);// vote is =0,nextprid initia is zero
    nextProposalId++;

}

function voteProposal(uint proposalId) public onlyInvestor{
    Proposal storage proposal=proposals[proposalId];//jo proposalId will get it will get to proposal 
    require(isVoted[msg.sender][proposalId]==false,"you have already voted");
    require(proposal.end>block.timestamp,"voting time ended");
    require(proposal.isExecuted==false,"it is already executed");
    isVoted[msg.sender][proposalId]=true;
    proposal.votes+=noOfShares[msg.sender];

    } 

    function executeProposal(uint proposalId) public onlyManager{
        Proposal storage proposal=proposals[proposalId];
        require(((proposal.votes*100)/totalShares)>=quorum,"majority doesnot support");//(50*100)/100 50-votes,/100=>nof shares
        proposal.isExecuted=true;
        avaialableFunds-=proposal.amount;
        _transfer(proposal.amount,proposal.receipent);
    }
    function _transfer(uint amount,address payable receipent) public {
        receipent.transfer(amount);
    }

//returnung data from mapping in array
    function proposalList() public view returns (Proposal[] memory){
        Proposal[] memory arr=new Proposal[](nextProposalId-1);//empty array of length= nextPropsalId-1
        for (uint i=1;i<nextProposalId;i++){
            arr[i]=proposals[i];
        }
        return arr;

    }











        
    


 



    }
