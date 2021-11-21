// SPDX-License-Identifier: GPL-3.0

/**
 *
 * Original code:
 * https://www.youtube.com/watch?v=dbmPkdMg_Fs
 *
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFT is ERC721 {
	address public artist;
	/**
	 * Address to deposit the fees
	 * (can be the artist, or some charity institution, etc)
	 */
	address public txFeeToken;
	uint256 public txFeeAmount;
	/**
	 * List of people who don't have to pay tax fees
	 */
	mapping(address => bool) public txFeeWhiteList;

	constructor(
		address _artist,
		address _txFeeToken,
		uint256 _txFeeAmount
	) ERC721("My NFT Name", "A Symbol?") {
		artist = _artist;
		txFeeToken = _txFeeToken;
		txFeeAmount = _txFeeAmount;

		txFeeWhiteList[_artist] = true;

		// What this does?
		// Only for tests purposes, not used in real world cases
		// (The "_mint" in the constructor, not the "_mint" himself)
		_mint(_artist, 0);
	}

	modifier isTheArtist() {
		require(
			msg.sender == artist,
			"Only artist can add people to the excluded list"
		);
		_;
	}

	function setWhiteList(address excludedAddress, bool status)
		external
		isTheArtist
	{
		txFeeWhiteList[excludedAddress] = status;
	}

	// Overrides a function of ERC721 to add tax fee logic
	function transferFrom(
		address from,
		address to,
		uint256 tokenId
	) public override {
		require(_isApprovedOrOwner(_msgSender(), tokenId));

		if (txFeeWhiteList[from] == false) {
			_payTxFee(from);
		}

		_transfer(from, to, tokenId);
	}

	// This is done so we can avoid the "payable" keyword,
	// whatever that is
	function _payTxFee(address from) internal {
		// This is the wallet / address?
		IERC20 token = IERC20(txFeeToken);

		token.transferFrom(from, artist, txFeeAmount);
	}
}
