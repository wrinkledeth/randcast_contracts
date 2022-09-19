// Using the ABIEncoderV2 poses little risk here because we only use it for fetching the byte arrays
// of shares/responses/justifications
// pragma experimental ABIEncoderV2;  // don't think we need this
pragma solidity ^0.8.15;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

import {Coordinator} from "src/Coordinator.sol";

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
        uint256 size; // 0
        uint256 threshold; // DEFAULT_MINIMUM_THRESHOLD
        Member[] members;
        // Member[] members; // BTreeMap::new(), TODO
    }

    // ! Group State Variables
    uint256 public groupCount; // Number of groups
    mapping(uint256 => Group) public groups; // group_index => Group struct

    // ! Member Struct
    struct Member {
        uint256 index;
        address node_id_address;
        bytes partial_public_key;
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
        rewards[msg.sender] = 0; // This is already true
        nodeJoin(msg.sender); // call node_join
    }

    // ! Node Join Stuff
    function nodeJoin(address idAddress) public {
        // * get groupIndex from findOrCreateTargetGroup -> addGroup
        (uint256 groupIndex, bool needsRebalance) = findOrCreateTargetGroup();
        addToGroup(idAddress, groupIndex, true); // * add to group
        // ! Reblance Group: Implement later!
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
        Group storage g = groups[groupCount++];
        g.index = groupCount;
        g.size = 0;
        g.threshold = DEFAULT_MINIMUM_THRESHOLD;
        // g.members.push(Member(0));
        return groupCount;
        // groupCount++; //increment group count
        // uint256 epoch = 0;

        // // Create Emtpy Member
        // uint256 zero = 0;

        // bytes memory partial_public_key = "";

        // groups[groupCount] = Group(
        //     groupCount,
        //     epoch,
        //     // Todo Member needs to be improved
        //     Member(zero, zero_addy, partial_public_key)
        // );
        // return groupCount;
    }

    function addToGroup(
        address idAddress,
        uint256 groupIndex,
        bool emitEventInstantly
    ) public returns (bool) {
        // Get group from group intex
        Group storage g = groups[groupIndex];

        // Add Member Struct to group at group index
        Member memory m;
        m.index = g.size;
        m.node_id_address = idAddress;

        // insert (node id address - > member) into group.members
        g.members.push(m);
        g.size++;

        // TODO: minimum = minimum threshold(group.size)

        if ((g.size >= 3) && emitEventInstantly) {
            emitGroupEvent(groupIndex);
        }
    }

    function emitGroupEvent(uint256 groupIndex) public {
        // TODO: Require groups.contains_key(&group_index)

        // TODO: Self.epoch += 1  (what is this??)

        // Increment group epoch
        Group storage g = groups[groupIndex];
        g.epoch++; // is this not it?

        Coordinator coordinator;

        coordinator = new Coordinator(
            // g.epoch, // ! epoch isnt in coordinator constructor atm.
            g.threshold,
            DEFAULT_DKG_PHASE_DURATION
        );
    }

    //! Getter function for testing, will be omitted.
    function getNode(address i) public view returns (address, bytes memory) {
        return (nodes[i].ip_address, nodes[i].id_public_key);
    }

    function getGroup(uint256 groupIndex) public view returns (Group memory) {
        return groups[groupIndex];
    }
}
