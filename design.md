# Controller Flow / Smart Contract Design

This note explores all the compenents of the controller contract and how they interact with each other.
(Note: need to draw a new design diagram)

We will consider if we can have an improved design for solidity contract.

Can we get rid of anything?

## Function List and Definitions

```rust
fn node_register(id_address: String, id_public_key:Vec<u8>) -> ControllerResult<()> 
// This function is called by a node to register itself with the controller.
// Create instance of node struct:  add node to nodes map / rewards map
// call node_join

fn node_join(id_address: String) -> ControllerResult<bool> 
// call find_or_create_target_group to get group_id and check if we need to reblance

fn add_group() -> usize 
// increment group index, populate group struct, insert group to groups map.

fn add_to_group(node_id_address: String, group_index: usize, emit_event_instantly: bool) -> ControllerResult<()> 
// create member struct from node_id_address, add to members map
// set minimum to minimum_threshold

fn minimum_threshold(n: usize) -> usize {(((n as f64) / 2.0) + 1.0) as usize}
// The minimum allowed threshold is 51%

 fn emit_group_event(group_index: usize) -> ControllerResult<()> 
// Increment group epoch: Number of times a group event was emitted for a particular group
// Increment epoch: Sum of all existing group epochs (version number tor synchroniztion between nodes, smart contract, and diff chains)
// Deploy new coordinator -> Initialize coordinator with members -> insert coordinator into the coordinator map
// Emit Event to kick off dkt task for nodes. 

fn rebalance_group(mut group_a_index: usize, mut group_b_index: usize) -> ControllerResult<bool> 
// Rebalance groups?? How does it work?

fn emit_dkg_task(&self) -> ControllerResult<DKGTask> {
// ?? How does this work? Why is it commented out

fn valid_group_indices(&self) -> Vec<usize> {
// ? 


```

## Rust Functions Flow

node_register:
  node_join:
    find_or_create_target_group
      valid_group_indices
      add_group
    add_to_group
      minimum_threshold  
      emit_group_event
        emit_dkg_task
    reblance_group
      choose_randomly_from_indices
      remove_from_group
      add_to_group
      emit_group_event

## Questions

### Controller Function

What do these functions do??
Rebalance Group?
Emit DKG Task?

Where are all the other functions called? (emit_dkg_task, commit_dkg, post_proccess_dkg etc...)

find_or_create_target_group (line 118), wtf???



### Design

emitGroupEvent: Epoch isnt in coordinator constructor.. how to address?




## Happy Path TODO

"require" tests:

- [x] test fail: emit group event for non existent group index
- [x] test fail: register a node that has already been registered 

node register

- [ ] Check to see if enough balance for staking
(What's going on here? Code seems to be gone)

node join

- [ ] Reblance Group: Implement later!
(need explanation of how this works)

find or create target group

- [ ] Need to implement index_of_min_size  
(need explanation of how this works)

add to group

- [x] minimum = minimum threshold(group.size)

emit group event

- [ ] Require !groups.contains_key(&group_index)
- [ ] is_strictly_majority_consensus, commit_cache, commiters
- [ ] group epoch isnt in coordinator constructor atm.
