// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Contract is Ownable {
    // Constructor Set Variables
    uint256 epoch;
    uint256 threshold;
    uint256 phase_duration;

    // initialize() set variables
    uint256 start_block;
    uint256 current_block;
    uint256 blocks_since_start;

    // member mappings
    mapping(address => uint256[]) keys; // Ethereum Address => BLS public keys
    mapping(address => uint256[]) shares; // Ethereum Address => DKG Phase 1 Shares
    mapping(address => uint256[]) responses; // Ethereum Address => DKG Phase 3 Justifications
    mapping(address => uint256[]) justifications; // Ethereum Address => DKG Phase 3 Justifications

    constructor() {}

    struct Member {
        address wallet_address;
        uint256 node_index; // index of node within group
        address dkg_key;
        /// @notice Explain to an end user what this does
        /// @dev Explain to a developer any extra details
        /// @return Documents the return variables of a contract’s function state variable
        /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    }

    function initialize(Member[3] calldata members) external onlyOwner {}

    function get_shares() external view {}
}
