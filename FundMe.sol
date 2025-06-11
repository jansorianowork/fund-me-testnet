// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { PriceConverter } from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    //Get funds from users
    //withdraw funds
    //set a minimum funding value in USD
    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;

    mapping(address funder=>uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;
    constructor(){
        i_owner = msg.sender;
    }

    function    fund() public payable {
        // number of wei
        require(msg.value.getConversionRate() > MINIMUM_USD, "not enough ETH");
        //revert - undo any actions that have been done, and send remaining gas back
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }
    function withdraw() public onlyOwner{
        //for loop
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
           address funder = funders[funderIndex];
           addressToAmountFunded[funder] = 0;
        }
        //reset array
        funders = new address[](0);
        //tranfer
        //payable address
        // payable(msg.sender).transfer(address(this).balance);
        // //send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");
        //call
        (bool callSucess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSucess, "Call Failed");
    }    //Noned

    modifier onlyOwner(){
        // require(msg.sender == i_owner, "Sender is not the owner!");
        if(msg.sender != i_owner){
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}