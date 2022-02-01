//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

contract Escrow is Initializable {
	// console.log("creating new escrow");
	address public freeflow;
	address payable public dev;
	address public client;

	bool public isApproved;

	function initialize(address _freeflow, address payable _dev, address _client) public payable initializer {
		freeflow = _freeflow;
		dev = _dev;
		client = _client;
	}

	event Approved(uint);

	function releaseFunds() external {
		require(msg.sender == freeflow);
		uint balance = address(this).balance;
		dev.transfer(balance);
		emit Approved(balance);
		isApproved = true;
	}
}
