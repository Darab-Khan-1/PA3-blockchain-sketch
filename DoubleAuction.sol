// SPDX-License-Identifier: HF
pragma solidity ^0.8.1;

/*
Feel free to create your own functions and interact with them in JavaScript
DO NOT CHANGE THE FUNCTION DEFINITIONS OF ANY OF THE FUNCTIONS ALREADY DEFINED BELOW

THE ONLY FUNCTION YOU ARE ALLOWED THE CHANGE THE DEFINITION OF IS getHistory().
You will probably need to change that.
*/

contract DoubleAuction 
{
    
   uint constant private maxSize = 20; //maximum number of bids
   uint constant private AuctionInterval = 30; //time in seconds. Contract shouldn't be called faster than this

    function addBuyer(uint quantity, uint price) public
    {
    	return;
    } 
   

    function addSeller(uint quantity, uint price) public
    {
       return;
    } 
    
    function doubleAuction() public 
    {

        return;
    }



    function getResults() public view returns(uint returnedInteger)
    {
        return 0;
    }    
    
    
}

