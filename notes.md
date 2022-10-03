# Controller Contract Design Notes

node_register(L740) -> node_join(L228) -> add_to_group(L511)

## Implement the following as a fist step

``` bash
node_register:  
  node_join: 
    find_or_create_target_group:
      add_group
    add_to_group:
      minimum_threshold  
      emit_group_event
```

## Design Exploration

``` bash

node_register:  
  node_join: 
    find_or_create_target_group:
      add_group
    add_to_group:
      minimum_threshold  
      emit_group_event 

```


## Suggested Usage

 forge test --match-contract Controller -vv

## Tasks

- [ ] FINISH controller prototype and tests. Integrate with coordinator
  - [x] Finish general code flow happy path.
  - [x] Happy path unit tests
  - [ ] Implement all functions (bad path)
  - [ ] Implement Post proccess DKG
  - [ ] Unit Tests
  - [ ] Integrate with coordinator tests
  - [ ] Optimize function / state keywords / types to save gas.

## meeting notes

- Nodecount consider 8bit.
- Consult excalidraw, be open to refactoring if needed. Rust code as a reference.
- Design components first, discuss before implementation.
- Might make sense to split controller into multiple parts.

- Draw new diagram for controller (focused on design over implementation).
- Consider if we can have an improved design for solidity contract.
- Can we get rid of anything?

## Questions

Line 106. Whats going on here.