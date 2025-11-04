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

    struct Bid {
        address bidder;
        uint quantity;
        uint price;
    }

    Bid[] private buyerBids;
    Bid[] private sellerBids;
    mapping(address => bool) private hasBidInCurrentInterval;
    address[] private addressesInCurrentInterval;
    uint private lastAuctionTime;
    
    struct MatchResult {
        address buyerAddress;
        address sellerAddress;
        uint quantity;
        uint clearingPrice;
    }
    
    MatchResult[] private lastResults;
    bool private hasResults;

    function addBuyer(uint quantity, uint price) public
    {
        require(!hasBidInCurrentInterval[msg.sender], "Address already has a bid in this auction interval");
        require(buyerBids.length < maxSize, "Maximum number of bids reached");
        require(msg.sender.balance >= quantity * price, "Insufficient balance");
        
        buyerBids.push(Bid({
            bidder: msg.sender,
            quantity: quantity,
            price: price
        }));
        
        hasBidInCurrentInterval[msg.sender] = true;
        addressesInCurrentInterval.push(msg.sender);
    } 
   

    function addSeller(uint quantity, uint price) public
    {
        require(!hasBidInCurrentInterval[msg.sender], "Address already has a bid in this auction interval");
        require(sellerBids.length < maxSize, "Maximum number of bids reached");
        
        sellerBids.push(Bid({
            bidder: msg.sender,
            quantity: quantity,
            price: price
        }));
        
        hasBidInCurrentInterval[msg.sender] = true;
        addressesInCurrentInterval.push(msg.sender);
    } 
    
    function doubleAuction() public 
    {
        require(lastAuctionTime == 0 || block.timestamp >= lastAuctionTime + AuctionInterval, "Auction interval has not passed");
        
        // Clear previous results
        delete lastResults;
        hasResults = false;
        
        // If no bids, return
        if (buyerBids.length == 0 || sellerBids.length == 0) {
            clearBids();
            lastAuctionTime = block.timestamp;
            return;
        }
        
        // Sort seller bids in ascending order (by price)
        sortSellersAscending();
        
        // Sort buyer bids in descending order (by price)
        sortBuyersDescending();
        
        // Find breakeven index k
        uint k = findBreakevenIndex();
        
        // If no breakeven index found, clear bids and return
        if (k == 0) {
            clearBids();
            lastAuctionTime = block.timestamp;
            return;
        }
        
        // Calculate clearing price
        uint clearingPrice = (buyerBids[k-1].price + sellerBids[k-1].price) / 2;
        
        // Match bids up to index k
        for (uint i = 0; i < k; i++) {
            uint quantity = buyerBids[i].quantity < sellerBids[i].quantity 
                ? buyerBids[i].quantity 
                : sellerBids[i].quantity;
            
            lastResults.push(MatchResult({
                buyerAddress: buyerBids[i].bidder,
                sellerAddress: sellerBids[i].bidder,
                quantity: quantity,
                clearingPrice: clearingPrice
            }));
        }
        
        hasResults = true;
        clearBids();
        lastAuctionTime = block.timestamp;
    }
    
    function sortSellersAscending() private {
        // Simple bubble sort for ascending order
        for (uint i = 0; i < sellerBids.length; i++) {
            for (uint j = 0; j < sellerBids.length - i - 1; j++) {
                if (sellerBids[j].price > sellerBids[j + 1].price) {
                    Bid memory temp = sellerBids[j];
                    sellerBids[j] = sellerBids[j + 1];
                    sellerBids[j + 1] = temp;
                }
            }
        }
    }
    
    function sortBuyersDescending() private {
        // Simple bubble sort for descending order
        for (uint i = 0; i < buyerBids.length; i++) {
            for (uint j = 0; j < buyerBids.length - i - 1; j++) {
                if (buyerBids[j].price < buyerBids[j + 1].price) {
                    Bid memory temp = buyerBids[j];
                    buyerBids[j] = buyerBids[j + 1];
                    buyerBids[j + 1] = temp;
                }
            }
        }
    }
    
    function findBreakevenIndex() private view returns (uint) {
        uint minLength = buyerBids.length < sellerBids.length 
            ? buyerBids.length 
            : sellerBids.length;
        
        uint k = 0;
        for (uint i = 0; i < minLength; i++) {
            if (buyerBids[i].price >= sellerBids[i].price) {
                k = i + 1;
            } else {
                break;
            }
        }
        
        return k;
    }
    
    function clearBids() private {
        delete buyerBids;
        delete sellerBids;
        
        // Clear the mapping by iterating through tracked addresses
        for (uint i = 0; i < addressesInCurrentInterval.length; i++) {
            hasBidInCurrentInterval[addressesInCurrentInterval[i]] = false;
        }
        delete addressesInCurrentInterval;
    }

    function getResults() public view returns(
        address[] memory buyerAddresses,
        address[] memory sellerAddresses,
        uint[] memory quantities,
        uint[] memory clearingPrices
    )
    {
        if (!hasResults || lastResults.length == 0) {
            return (new address[](0), new address[](0), new uint[](0), new uint[](0));
        }
        
        uint length = lastResults.length;
        buyerAddresses = new address[](length);
        sellerAddresses = new address[](length);
        quantities = new uint[](length);
        clearingPrices = new uint[](length);
        
        for (uint i = 0; i < length; i++) {
            buyerAddresses[i] = lastResults[i].buyerAddress;
            sellerAddresses[i] = lastResults[i].sellerAddress;
            quantities[i] = lastResults[i].quantity;
            clearingPrices[i] = lastResults[i].clearingPrice;
        }
    }
    
    
}

