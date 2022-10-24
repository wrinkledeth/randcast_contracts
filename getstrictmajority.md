# Get Strict Majority Commitment Result

Member "push" is not available in bytes32[] memory outside of storage.

```js
        bytes32[] memory commitResultsSeen;
```

---

This was a dirty implementation using storage maps since maps cant be created in functions.

```js
    mapping(bytes32 => address[]) commitResultToNodes;
    mapping(bytes32 => bool) commitResultSeen; // keep track of commit results seen

    // Goal: get array of majority members with identical commit result
    function getStrictlyMajorityIdenticalCommitmentResult(uint256 groupIndex)
        internal
        returns (bool, address[] memory)
    {
        Group memory g = groups[groupIndex]; // get group from group index

        // Populate commitResultToNodes with identical commit results => node array
        for (uint256 i = 0; i < g.commitCache.length; i++) {
            CommitCache memory commitCache = g.commitCache[i];
            bytes32 commitResultHash = keccak256(
                abi.encode(commitCache.commitResult)
            );
            if (commitResultSeen[commitResultHash]) {
                commitResultToNodes[commitResultHash].push(
                    g.commitCache[i].nodeIdAddress
                );
            } else {
                commitResultSeen[commitResultHash] = true;
                commitResultToNodes[commitResultHash] = new address[](0);
                commitResultToNodes[commitResultHash].push(
                    g.commitCache[i].nodeIdAddress
                );
            }
        }

        // iterate through commitResultToNodes and check if majority exists. If it does, return the nodes
        for (uint256 i = 0; i < g.commitCache.length; i++) {
            CommitCache memory commitCache = g.commitCache[i];
            bytes32 commitResultHash = keccak256(
                abi.encode(commitCache.commitResult)
            );
            if (
                commitResultToNodes[commitResultHash].length >
                g.members.length / 2
            ) {
                // g.isStrictlyMaj[[orityConsensusReached = true;
                return (true, commitResultToNodes[commitResultHash]);
            }
        }
        return (false, new address[](0));
    }
    ```