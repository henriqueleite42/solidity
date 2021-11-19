// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * Election
 *
 * Implements voting process along with vote delegation
 */
contract Election {

	struct Voter {
		uint weight; // weight is accumulated by delegation
		bool voted;  // if true, that person already voted
		address delegate; // person delegated to
		uint vote;   // index of the voted candidate
	}

	struct Candidate {
		// If you can limit the length to a certain number of bytes,
		// always use one of bytes1 to bytes32 because they are much cheaper
		bytes32 name;   // short name (up to 32 bytes)
		uint voteCount; // number of accumulated votes
	}

	address public chairperson;

	bool public closed;

	mapping(address => Voter) public voters;

	Candidate[] public candidates;

	/**
		* Create a new ballot to choose one of 'candidateNames'.
		*
		* @param candidateNames names of candidates
		*/
	constructor(bytes32[] memory candidateNames, address[] memory votersAdresses) {
		chairperson = msg.sender;

		/**
		 * Define the candidates
		 */
		for (uint i = 0; i < candidateNames.length; i++) {
			candidates.push(Candidate({
				name: candidateNames[i],
				voteCount: 0
			}));
		}

		/**
		 * Define the voters
		 */
		voters[chairperson].weight = 1;

		for (uint i = 0; i < votersAdresses.length; i++) {
			voters[votersAdresses[i]].weight = 1;
		}
	}

	/**
		* Delegate your vote to the voter 'to'.
		*
		* @param to address to which vote is delegated
		*/
	function delegate(address to) public {
		require(closed, "Election has already been closed.");

		Voter storage sender = voters[msg.sender];

		require(!sender.voted, "You already voted.");

		require(to != msg.sender, "Self-delegation is disallowed.");

		while (voters[to].delegate != address(0)) {
			to = voters[to].delegate;

			// We found a loop in the delegation, not allowed.
			require(to != msg.sender, "Found loop in delegation.");
		}

		sender.delegate = to;

		Voter storage delegate_ = voters[to];

		delegate_.weight += sender.weight;

		if (delegate_.voted) {
			// If the delegate already voted,
			// directly add to the number of votes
			candidates[delegate_.vote].voteCount += sender.weight;
		}
	}

	/**
	 * Undelegate your vote to the voter 'to'.
	 */
	function undelegate() public {
		require(closed, "Election has already been closed.");

		Voter storage sender = voters[msg.sender];

		Voter storage delegate_ = voters[sender.delegate];

		if (delegate_.voted) {
			candidates[delegate_.vote].voteCount -= sender.weight;
		}

		/**
		 * Removes the weight recursivelly
		 */
		address to = sender.delegate;
		while (voters[to].delegate != address(0)) {
			voters[to].weight -= sender.weight;

			to = voters[to].delegate;
		}
	}

	/**
		* Give your vote (including votes delegated to you) to
		* candidate 'candidates[candidate].name'.
		*
		* @param candidate index of candidate in the candidates array
		*/
	function vote(uint candidate) public {
		require(closed, "Election has already been closed.");

		Voter storage sender = voters[msg.sender];

		require(sender.weight == 0, "Has no right to vote");

		require(sender.delegate != address(0), "Right to vote delegated");

		require(!sender.voted, "Already voted.");

		sender.voted = true;
		sender.vote = candidate;

		// If 'candidate' is out of the range of the array,
		// this will throw automatically and revert all
		// changes.
		candidates[candidate].voteCount += sender.weight;
	}

	/**
		* Closes the election and computes the winning candidate taking
		* all previous votes into account.
		*
		* @return winnerName_ name of winning candidate in the candidates array
		*/
	function result() public returns (bytes32 winnerName_) {
		closed = true;

		uint winningCandidate = 0;
		uint winningVoteCount = 0;
		for (uint p = 0; p < candidates.length; p++) {
			if (candidates[p].voteCount > winningVoteCount) {
				winningVoteCount = candidates[p].voteCount;
				winningCandidate = p;
			}
		}

		winnerName_ = candidates[winningCandidate].name;
	}
}
