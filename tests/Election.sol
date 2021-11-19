// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.

import "../contracts/Election.sol";

contract ElectionTest {
	bytes32[] candidatesNames;
	address[] votersAddresses;

	Election electionToTest;

	function beforeAll () public {
		candidatesNames.push(bytes32("candidate1"));
		candidatesNames.push(bytes32("candidate2"));

		votersAddresses.push(address(0xc0ffee254729296a45a3885639AC7E10F9d54979));
		votersAddresses.push(address(0x999999cf1046e68e36E1aA2E0E07105eDDD1f08E));

		electionToTest = new Election(candidatesNames, votersAddresses);
	}

	function checkWinningProposal () public {
		electionToTest.vote(0);

		Assert.equal(electionToTest.result(), bytes32("candidate1"), "candidate1 should be the winner name");
	}
}
