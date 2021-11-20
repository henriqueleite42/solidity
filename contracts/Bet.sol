// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * Bet
 *
 * Will manage bets and tell who win and how much they earn
 */
contract Bet {
	// Map of teams, to know if a team exists
	mapping(bytes32 => bool) public teams;

	// Team -> How much the people bet in it
	mapping(bytes32 => uint256) public sumOfBets;

	// Team -> People who bet in that team
	mapping(bytes32 => address[]) public bets;

	bool closed;

	bytes32 winnerTeam;

	// Can be replaced by a time event, so it gets completly decentralized?
	address chairperson;

	/**
	 * Set teams that can be beted
	 */
	constructor(bytes32[] memory teams_) {
		chairperson = msg.sender;

		for (uint256 i = 0; i < teams_.length; i++) {
			sumOfBets[teams_[i]] = 0;
			// bets[teams_[i]] = []; Arrays don't need to be initialized
			teams[teams_[i]] = true;
		}
	}

	// Check if the msg sender is the chairperson
	modifier isChairperson() {
		require(msg.sender != chairperson, "Only the chairperson can do this");
		_;
	}

	// Check if the bets are open
	modifier isOpen() {
		require(closed != true, "Bets was closed");
		_;
	}

	// Check if the bets are open
	modifier isClosed() {
		require(closed == true, "Bets istill ongoing");
		_;
	}

	// Check if the winner has not beign defined yet
	modifier notHasWinnerTeam() {
		require(winnerTeam == 0, "The winner has not beign decided yet");
		_;
	}

	// Check if the winner has not beign defined yet
	modifier hasWinnerTeam() {
		require(winnerTeam != 0, "The winner has already being decided");
		_;
	}

	// Check if the team exists
	modifier teamExists(bytes32 team) {
		require(!teams[team] == true, "Team does not exists");
		_;
	}

	/**
	 * Register a new bet
	 *
	 * @param team -> The team to bet in
	 * @param qtd -> Quantity to bet
	 */
	function newBet(bytes32 team, uint256 qtd) public isOpen teamExists(team) {
		sumOfBets[team] += qtd;
		bets[team].push(msg.sender);
	}

	/**
	 * Close the bets
	 */
	function closeBets() public isChairperson isOpen {
		closed = true;
	}

	/**
	 * Set the winner team
	 */
	function setWinnerTeam(bytes32 winnerTeam_) public isClosed notHasWinnerTeam {
		winnerTeam = winnerTeam_;
	}

	/**
	 * Returns how much each beter win
	 */
	function getResult() public view hasWinnerTeam returns (uint256 prize) {
		return sumOfBets[winnerTeam] / bets[winnerTeam].length;
	}

	/**
	 * Returns the winners of the bet
	 */
	function getWinners() public view hasWinnerTeam returns (address[] memory) {
		return bets[winnerTeam];
	}
}
