// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract TimelockEscrow {
    address public seller;
    // I am using 3 minutes because of testing; you can change it to 3 days
    uint256 lockTime = 5 minutes;
    uint256 startTime;
    mapping(address => uint256) public escrowedAmount;

    /**
     * The goal of this exercise is to create a Time lock escrow.
     * A buyer deposits ether into a contract, and the seller cannot withdraw it until 3 days passes. Before that, the buyer can take it back
     * Assume the owner is the seller
     */

    constructor() {
        seller = msg.sender;
        
    }

    // creates a buy order between msg.sender and seller
    /**
     * escrows msg.value for 5 minutes which buyer can withdraw at any time before 3 days, but after which only seller can withdraw
     * should revert if an active escrow still exists or last escrow hasn't been withdrawn
     */
    function createBuyOrder() external payable {
        startTime = block.timestamp;
        require(msg.sender != seller, "Seller cannot create a buy order");
        require(escrowedAmount[msg.sender] == 0, "Active escrow still exists");

        escrowedAmount[msg.sender] = msg.value;
    }

    /**
     * allows seller to withdraw after 5 minutes of the escrow with @param buyer has passed
     */
    function sellerWithdraw(address buyer) external {
        require(msg.sender == seller, "Only seller can withdraw");
        require(escrowedAmount[buyer] > 0, "No escrowed amount for the buyer");

        require(block.timestamp >= startTime + lockTime, "Lock time has not passed yet");

        uint256 amount = escrowedAmount[buyer];
        escrowedAmount[buyer] = 0;

        (bool success, ) = seller.call{value: amount}("");
        require(success, "Seller withdrawal failed");
    }

    /**
     * allows buyer to withdraw at any time before the end of the escrow (3 days)
     */
    function buyerWithdraw() external {
        require(escrowedAmount[msg.sender] > 0, "No escrowed amount for the buyer");

        uint256 amount = escrowedAmount[msg.sender];
        escrowedAmount[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Buyer withdrawal failed");
    }
}
