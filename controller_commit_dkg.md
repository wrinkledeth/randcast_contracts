# Commit DKG

``` rust
    fn commit_dkg(
        &mut self,
        id_address: String,
        group_index: usize,
        group_epoch: usize,
        public_key: Vec<u8>,
        partial_public_key: Vec<u8>,
        disqualified_nodes: Vec<String>,
    ) -> ControllerResult<()> {
```

## Structs

Commit Cache

```rust
        // * Create commit result struct
        let commit_result = CommitResult {
            group_epoch,
            public_key,
            disqualified_nodes,
        };

        // * Create CommitCache struct
        let commit_cache = CommitCache {
            commit_result,
            partial_public_key: partial_public_key.clone(),
        };
```

DKG Task

```rust
        let dkg_task = DKGTask {
            group_index: group.index,
            epoch: group.epoch,
            size: group.size,
            threshold: group.threshold,
            members,
            assignment_block_height: self.block_height,
            coordinator_address,
        };
```

---

Group

```rust
        let group = Group {
            index: group_index,
            epoch: 0,
            capacity: GROUP_MAX_CAPACITY,
            size: 0,
            threshold: DEFAULT_MINIMUM_THRESHOLD,
            is_strictly_majority_consensus_reached: false,
            public_key: vec![],
            fail_randomness_task_count: 0,
            members: BTreeMap::new(),
            committers: vec![],
            commit_cache: BTreeMap::new(),
        };
```

Node

```rust
        let node = Node {
            id_address: id_address.clone(),
            id_public_key,
            state: true,
            pending_until_block: 0,
            staking: NODE_STAKING_AMOUNT,
        };
```

Member

```rust
        let member = Member {
            index: group.size,
            id_address: node_id_address.clone(),
            partial_public_key: vec![],
        };
```

