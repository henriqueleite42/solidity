// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * Storage
 *
 * Store & retrieve value in a variable
 */
contract CatGenetics {
	struct Cat {
		uint256 color;
		// [Color, InheritanceChance]
		uint256[][] genetics;
	}

	// The probability of having any color from the parents
	mapping(uint256 => uint256) probability;

	function setParentGen(Cat memory parent) internal {
		for (uint256 i = 0; i < parent.genetics.length; i++) {
			uint256[] memory gen = parent.genetics[i];

			uint256 parentColor = gen[0];
			uint256 inheritancePercentage = gen[1];

			/**
			 * Divides by two, so both father and
			 * mother genetics added together makes
			 * 100% (or almost it)
			 */
			uint256 inheritance = inheritancePercentage / 2;

			probability[parentColor] = inheritance;
		}
	}

	constructor(Cat memory father, Cat memory mother) {
		setParentGen(father);

		setParentGen(mother);

		// So what?
		// Solidity does not support randomness
	}
}
