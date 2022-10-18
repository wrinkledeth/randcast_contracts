pragma solidity ^0.8.15;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";

import {Coordinator} from "src/Coordinator.sol";
import "src/ICoordinator.sol";

contract Controller is Ownable {
    // ! Constants
    uint256 public constant NODE_STAKING_AMOUNT = 50000;
    uint256 public constant DISQUALIFIED_NODE_PENALTY_AMOUNT = 1000;
    uint256 public constant COORDINATOR_STATE_TRIGGER_REWARD = 100;
    uint256 public constant DEFAULT_MINIMUM_THRESHOLD = 3;
    uint256 public constant DEFAULT_NUMBER_OF_COMMITTERS = 3;
    uint256 public constant DEFAULT_DKG_PHASE_DURATION = 10;
    uint256 public constant GROUP_MAX_CAPACITY = 10;
    uint256 public constant IDEAL_NUMBER_OF_GROUPS = 5;
    uint256 public constant PENDING_BLOCK_AFTER_QUIT = 100;

    uint256 epoch = 0; // self.epoch, previously ined in adapter

    //  Node State Variables
    mapping(address => Node) public nodes; //maps node address to Node Struct
    mapping(address => uint256) public rewards; // maps node address to reward amount
    mapping(address => bool) public nodeRegistered; // map for checking if nodes are registered

    struct Node {
        address idAddress;
        bytes dkgPublicKey;
        bool state;
        uint256 pending_until_block;
        uint256 staking;
    }

    // Group State Variables
    uint256 public groupCount; // Number of groups
    mapping(uint256 => Group) public groups; // group_index => Group struct
    mapping(uint256 => bool) public groupRegistered; // map for checking if group exists

    struct Group {
        uint256 index; // group_index
        uint256 epoch; // 0
        uint256 size; // 0
        uint256 threshold; // DEFAULT_MINIMUM_THRESHOLD
        Member[] members; // ! Drop storage mapping and iterate via view function
        address[] committers;
        CommitCache[] commitCache; // ! Drop storage mapping and iterate via view function
        bool isStrictlyMajorityConsensusReached;
    }

    struct Member {
        uint256 index;
        address nodeIdAddress;
        bytes partialPublicKey;
    }

    // ! Coordinator State Variables
    mapping(uint256 => address) public coordinators; // maps group index to coordinator address

    // ! Functions
    function nodeRegister(bytes calldata dkgPublicKey) public {
        require(!nodeRegistered[msg.sender], "Node is already registered"); // error sender already in list of nodes

        // TODO: Check to see if enough balance for staking

        // Populate Node struct and insert into nodes
        Node storage n = nodes[msg.sender];
        n.idAddress = msg.sender;
        n.dkgPublicKey = dkgPublicKey;
        n.state = true;
        n.pending_until_block = 0;
        n.staking = NODE_STAKING_AMOUNT;

        nodeRegistered[msg.sender] = true;
        rewards[msg.sender] = 0; // This can be removed
        nodeJoin(msg.sender);
    }

    function nodeJoin(address idAddress) private {
        // * get groupIndex from findOrCreateTargetGroup -> addGroup
        (uint256 groupIndex, bool needsRebalance) = findOrCreateTargetGroup();
        addToGroup(idAddress, groupIndex, true); // * add to group
        // TODO: Reblance Group: Implement later!
        // if (needsRebalance) {
        //     // reblanceGroup();
        // }
    }

    // function reblanceGroup(uint256 groupIndexA, uint256 groupIndexB) private {}

    function findOrCreateTargetGroup()
        private
        returns (
            uint256, //groupIndex
            bool // needsRebalance
        )
    {
        if (groupCount == 0) {
            uint256 groupIndex = addGroup();
            return (groupIndex, false);
        }
        return (1, false); // TODO: Need to implement index_of_min_size
    }

    function addGroup() private returns (uint256) {
        groupCount++; // * Ruoshan, why does this break if ++ moved to next line?
        Group storage g = groups[groupCount];
        groupRegistered[groupCount] = true;
        g.index = groupCount;
        g.size = 0;
        g.threshold = DEFAULT_MINIMUM_THRESHOLD;
        return groupCount;
    }

    function addToGroup(
        address idAddress,
        uint256 groupIndex,
        bool emitEventInstantly
    ) private {
        // Get group from group index
        Group storage g = groups[groupIndex];

        // Add Member Struct to group at group index
        Member memory m;
        m.index = g.size;
        m.nodeIdAddress = idAddress;

        // insert (node id address - > member) into group.members
        g.members.push(m);
        g.size++;

        memberRegistered[groupIndex][idAddress] = true;

        // assign group threshold
        uint256 minimum = minimumThreshold(g.size); // 51% of group size
        // max of 51% of group size and DEFAULT_MINIMUM_THRESHOLD
        g.threshold = minimum > DEFAULT_MINIMUM_THRESHOLD
            ? minimum
            : DEFAULT_MINIMUM_THRESHOLD;

        if ((g.size >= 3) && emitEventInstantly) {
            emitGroupEvent(groupIndex);
        }
    }

    function minimumThreshold(uint256 groupSize)
        private
        pure
        returns (uint256)
    {
        uint256 min = groupSize / 2 + 1;
        return min;
    }

    function emitGroupEvent(uint256 groupIndex) private {
        require(groupRegistered[groupIndex], "Group does not exist"); // group must exist

        epoch++; // increment adapter epoch

        Group storage g = groups[groupIndex];
        g.epoch++;

        // TODO: is_strictly_majority_consensus, commit_cache, commiters

        Coordinator coordinator;

        coordinator = new Coordinator(
            // g.epoch, // TODO: epoch isnt in coordinator constructor atm.
            g.threshold,
            DEFAULT_DKG_PHASE_DURATION
        );

        coordinators[groupIndex] = address(coordinator);
    }

    // ! Commit DKG

    // struct Group {  // ! Copy for reference
    //     uint256 index; // group_index
    //     uint256 epoch; // 0
    //     uint256 size; // 0
    //     uint256 threshold; // DEFAULT_MINIMUM_THRESHOLD
    //     Member[] members;
    //     mapping(address => bool) memberRegistered; // map for checking if member exists
    //     address[] committers;
    //     CommitCache[] commitCache;
    // }

    // groupindex -> member registered -> true / false
    // ! Drop storage mappings and iterate via view function
    mapping(uint256 => mapping(address => bool)) internal memberRegistered; // map for checking if committer exists
    mapping(uint256 => mapping(bytes => bool)) internal partialKeysRegistered; // map for checking if committer exists

    struct CommitResult {
        uint256 groupEpoch;
        bytes publicKey;
        address[] disqualifiedNodes;
    }

    struct CommitCache {
        CommitResult commitResult;
        bytes partialPublicKey;
    }

    function commitDkg(
        address idAddress,
        uint256 groupIndex,
        uint256 groupEpoch,
        bytes calldata publicKey,
        bytes calldata partialPublicKey,
        address[] calldata disqualifiedNodes
    ) public {
        require(groupRegistered[groupIndex], "Group does not exist"); // require group exists

        // TODO: Bincode deserialize
        // Check if coordinator exists
        require(
            coordinators[groupIndex] != address(0),
            "Coordinator not found for groupIndex"
        ); // require coordinator exists

        // Get coordinator for associated groupIndex
        ICoordinator coordinator = ICoordinator(coordinators[groupIndex]);

        // TODO: Error if out of phase (if coordinato.in_phase().is_err() ??  Controller only goes up to phase 3)
        int8 phase = coordinator.inPhase(); // get current phase
        require(phase != -1, "DKG Has ended"); // require coordinator is in phase 1

        Group storage g = groups[groupIndex]; // get group from group index

        // Require ID Address to be present in list of members.
        require(
            !memberRegistered[groupIndex][idAddress],
            "Node is not a member of group"
        );

        // Require commit DKG group epoch to be the same as the Controlle Group epoch
        require(
            groupEpoch == g.epoch,
            "Commig DKG Group epoch does not match Controller Group epoch"
        );

        // Ensure Commit Cache does not already contain the key for this node
        require(
            !partialKeysRegistered[groupIndex][partialPublicKey],
            "Commit Cache already contains partial public key for this node"
        );

        // Create commit result / commit cache struct, and insert into g.commitCache
        CommitResult memory commitResult = CommitResult({
            groupEpoch: groupEpoch,
            publicKey: publicKey,
            disqualifiedNodes: disqualifiedNodes
        });

        CommitCache memory commitCache = CommitCache({
            commitResult: commitResult,
            partialPublicKey: partialPublicKey
        });

        g.commitCache.push(commitCache);

        // Update partialKeysRegistered
        partialKeysRegistered[groupIndex][partialPublicKey] = true;

        // If strictly majority consencus reached:
        if (g.isStrictlyMajorityConsensusReached) {
            // Member[] memory members = g.members;

            // assign member partial public keys
            for (uint256 i = 0; i < g.members.length; i++) {
                Member memory member = g.members[i];
                member.partialPublicKey = partialPublicKey;
            }
        } else {
            // check if strictly majority consensus reached
            // TODO: draw the rest of the owl
        }
    }

    // ! Post Proccess DKG

    // ************************************************** //
    // * Public Test functions for testing private stuff
    // * DELETE LATER
    // ************************************************** //

    function tNonexistantGroup(uint256 groupIndex) public {
        emitGroupEvent(groupIndex);
    }

    function tMinimumThreshold(uint256 groupSize)
        public
        pure
        returns (uint256)
    {
        return minimumThreshold(groupSize);
    }

    function getNode(address nodeAddress) public view returns (Node memory) {
        return nodes[nodeAddress];
    }

    function getGroup(uint256 groupIndex) public view returns (Group memory) {
        // ! This was broken by nested mappings
        return groups[groupIndex];
    }

    function getMember(uint256 groupIndex, uint256 memberIndex)
        public
        view
        returns (Member memory)
    {
        return groups[groupIndex].members[memberIndex];
    }

    function getCoordinator(uint256 groupIndex) public view returns (address) {
        return coordinators[groupIndex];
    }
}
