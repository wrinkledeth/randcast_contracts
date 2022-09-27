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

## Suggested Usage

 forge test --match-contract Controller -vv

## Tasks

- [ ] FINISH controller prototype and tests. Integrate with coordinator
  - [x] Finish general code flow happy path.
  - [x] Write unit tests
  - [ ] Integrate with coordinator tests
  - [ ] Optimize function and state keywords to save gas.

## Questions

Line 106. Whats going on here.
 