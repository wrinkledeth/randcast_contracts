// Using the ABIEncoderV2 poses little risk here because we only use it for fetching the byte arrays
// of shares/responses/justifications
// pragma experimental ABIEncoderV2;  // don't think we need this
pragma solidity ^0.8.15;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Controller is Ownable {
    //! Constants
    uint256 public immutable NODE_STAKING_AMOUNT = 50000;
    uint256 public immutable DISQUALIFIED_NODE_PENALTY_AMOUNT = 1000;
    uint256 public immutable COORDINATOR_STATE_TRIGGER_REWARD = 100;
    uint256 public immutable DEFAULT_MINIMUM_THRESHOLD = 3;
    uint256 public immutable DEFAULT_NUMBER_OF_COMMITTERS = 3;
    uint256 public immutable DEFAULT_DKG_PHASE_DURATION = 10;
    uint256 public immutable GROUP_MAX_CAPACITY = 10;
    uint256 public immutable IDEAL_NUMBER_OF_GROUPS = 5;
    uint256 public immutable PENDING_BLOCK_AFTER_QUIT = 100;

    //! Node Struct
    struct Node {
        address ip_address;
        bytes id_public_key;
        bool state;
        uint256 pending_until_block;
        uint256 staking;
    }

    //! Node State Variables
    mapping(address => Node) public nodes; //maps node address to Node Struct
    mapping(address => uint256) public rewards; // maps node address to reward amount
    mapping(address => bool) public nodeRegistered; // map for checking if nodes are registered

    // ! Group Struct (line 348)
    struct Group {
        uint256 index; // group_index
        uint256 epoch; // 0
        // address[] Member;
        // Member[] members; // BTreeMap::new(), TODO
    }

    // ! Group State Variables
    uint256 public groupCount; // Number of groups
    mapping(uint256 => Group) public groups; // group_index => Group struct

    // ! Member Struct
    struct Member {
        uint256 index;
    }

    function nodeRegister(bytes calldata id_public_key) public {
        // dkg public key as input
        // Check to see if msg.sender is already in list of nodes, error if so.
        require(!nodeRegistered[msg.sender]);

        // TODO: Check to see if enough balance for staking

        // Insert node into nodes map
        nodes[msg.sender] = Node(
            msg.sender,
            id_public_key,
            true,
            0,
            NODE_STAKING_AMOUNT
        );

        nodeRegistered[msg.sender] = true;

        // Start tracking rewards (not needed)
        // rewards[msg.sender] = 0; // This is already true

        // call nodeJoin
        nodeJoin(msg.sender);
    }

    // ! Node Join Stuff
    function nodeJoin(address idAddress) public {
        // * get group index from findOrCreateTargetGroup
        (uint256 groupIndex, bool needsRebalance) = findOrCreateTargetGroup();

        // * Add to group
        addToGroup(idAddress, groupIndex, true);

        // * Reblance Group: Implement later!
    }

    function findOrCreateTargetGroup()
        public
        returns (uint256 groupIndex, bool needsRebalance)
    {
        if (groupCount == 0) {
            groupIndex = addGroup();
        }
        return (groupIndex, false);
    }

    function addGroup() public returns (uint256) {
        groupCount++; //increment group count
        uint256 epoch = 0;

        // insert new group struct
        groups[groupCount] = Group(
            groupCount,
            epoch
            // TODO: Empty Members struct here.
        );
        return groupCount;
    }

    function addToGroup(
        address idAddress,
        uint256 groupIndex,
        bool emitEventInstantly
    ) public returns (bool) {
        // Get group from group intex
        // Create Member = Member Struct
        // group.size ++
        // insert (node id address - > member) into group.members
        // minimum = minimum threshold
        // if groupsize >=3: emit_group_event
    }

    function getNode(address i) public view returns (address, bytes memory) {
        return (nodes[i].ip_address, nodes[i].id_public_key);
    }

    // function addGroup() public {
    //     fn add_group(&mut self) -> usize {  //! create new group and assign group index.
    //         let group_index = self.groups.len() + 1;
    //     uint groupLen = 0;
    //     groups[grouplen] = Group(
    //         uint256 index; // group_index
    //         uint256 epoch; // 0
    //         uint256 capacity; // GROUP_MAX_CAPACITY,
    //         uint256 size; // 0,
    //         uint256 threshold; // DEFAULT_MINIMUM_THRESHOLD,
    //         bool is_strictly_majority_consensus_reached; // false,
    //         bytes[] public_key; // vec![], TODO
    //         uint256 fail_randomness_task_count; // 0,
    //         bytes[] members;  // BTreeMap::new(), TODO
    //         bytes[] committers; // vec![],
    //         bytes[] commit_cache; // BTreeMap::new(), TODO
    //     );
    //         self.groups.insert(group_index, group);
    //         group_index
    //     }
    // }
    function addToGroup() public {}

    function emitGroupEvent(uint256 groupIndex) public {}
}
