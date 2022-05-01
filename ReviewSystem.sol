// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

/**
 * @title Review
 * @dev A transaction with review from buyer
 */
contract ReviewSystem{

    struct Asset{
        string name;
        uint price;
        string hash;
        uint rating;
        uint totalReviewed;
        bool dealDone;
        address[] owners;
    }

    struct Transact{
        uint assetId;
        uint value;
        address buyer;
        address seller;
    }

    struct Review{
        uint rating;
        string comment;
        uint dateOfReview;
    }
    
    Asset newAsset;

    Transact newTransact;

    Review newReview;

    uint public TotalAsset;

    mapping(uint => Asset) assetDetail;

    uint[] public AssetIds;

    mapping(uint => mapping(address => Transact)) transactDetail;

    mapping(uint => mapping(address => Review)) reviewDetail;

    // events
    event addTransactEvent( uint id);

    event addAssetEvent( uint id, string name);

    event reviewAssetEvent( uint id, uint rating);

    constructor() {
        console.log("Owner contract deployed by:", msg.sender);
        TotalAsset = 0;
    }

    /**
    * @dev Add an asset
    */
    function addAsset(string memory name, uint price, string memory hash) public {
        require(keccak256(bytes(name)) != keccak256(""), "Asset Name required !");

         TotalAsset++;
         uint id = TotalAsset + 5012022;
        
        newAsset.name = name;
        newAsset.price = price;
        newAsset.hash = hash;
        newAsset.rating = 0;
        newAsset.totalReviewed = 0;
        newAsset.dealDone = false;
        newAsset.owners.push(msg.sender);


        AssetIds.push(id);
        assetDetail[id] = newAsset;
        
        emit addAssetEvent(id, name);
        
    }

    function getTotalAssets() public returns(uint) {
        return TotalAsset;
    }
    
    function getAsset(uint id) public returns(string memory, uint, uint, uint, bool, address) {
        return (assetDetail[id].name, assetDetail[id].price, assetDetail[id].rating, assetDetail[id].totalReviewed, assetDetail[id].dealDone, assetDetail[id].owners[assetDetail[id].owners.length]);
    }

    function getAllAssetids() public returns (uint[] memory) {
        return AssetIds;
    }

    function getAllOwnersForAsset(uint id) public returns (address[] memory){
       return assetDetail[id].owners;
    }

    /**
     * @dev Transact purchase for an asset
     */
    function transact(uint assetId) payable public{
        newTransact.assetId = assetId;
        newTransact.value = msg.value;
        newTransact.buyer = msg.sender;

        Asset storage oldAsset = assetDetail[assetId];
        address priorOwner = oldAsset.owners[oldAsset.owners.length - 1];
        newTransact.seller = priorOwner;

        oldAsset.dealDone = true;
        oldAsset.owners.push(msg.sender);

        transactDetail[assetId][msg.sender] = newTransact;

        emit addTransactEvent(assetId);
    }

    /**
     * @dev Leave a review
     */
     function writeReview(uint assetId, uint rating, string memory comment, uint reviewDate) public {
        require(assetId >= 0, "Assetid required!");
        require(rating >= 0 && rating <= 5, "Product rating should be in 0~5 range!");

        Asset storage oldAsset = assetDetail[assetId];
        require(oldAsset.dealDone == true, "Not yet been sold.");
        address currentOwner = oldAsset.owners[oldAsset.owners.length - 1];
        require(msg.sender == currentOwner, "Not valid request to review.");

        Transact storage oldTransaction = transactDetail[assetId][msg.sender];
        oldAsset.rating += rating * oldTransaction.value;
        oldAsset.totalReviewed++;
        
        newReview.rating = rating;
        newReview.comment = comment;
        newReview.dateOfReview = reviewDate;

        reviewDetail[assetId][msg.sender] = newReview;

        emit reviewAssetEvent(assetId, rating);
     }

     function getAssetRating(uint id) public view returns (string memory name, uint rating) {
        require(id >= 0, "Productid required !");
        
        uint allRating = 0;

        if(assetDetail[id].totalReviewed > 0)
            allRating = assetDetail[id].rating / assetDetail[id].totalReviewed;
        
        return (assetDetail[id].name, allRating);
    }

    function getCurrentUserComments(uint id) public view returns (string memory) {
         require(id >= 0, "Assetid required !");
         
         return reviewDetail[id][msg.sender].comment;
         
    }

    function getUserRating(uint id, address user) public view returns (uint) {
         require(id >= 0, "Assetid required !");
         
         return reviewDetail[id][user].rating;
         
    }
    
    function getUserDateOfReview(uint id, address user) public view returns (uint reviewDate) {
         require(id >= 0, "Assetid required !");
         
         return reviewDetail[id][user].dateOfReview;
         
    }

}
