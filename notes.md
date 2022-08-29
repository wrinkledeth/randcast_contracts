# Coordinator Deveopment Notes

## Differences

Constructor

- Celo takes two args: threshold, phase duration
- Randcast takes 3: group.epoch, threshold, phase duration
  - group epoch is incremented each time "emit_group_event" is run.
  - emit group event runs everytime a dkg proccess is kicked off, either via a new coordinator or regrouping

Ownable

- Celo uses custom owner only code.
  - owner = msg.sender (set in constructor)
  - require(msg.sender == owner, "only owner may allowlist users");
- Randcast will use openzeppelin ownable modifier

Modifiers

- Celo has:
  - onlyRegistered (modifier for publish)
  - onlyWhenNotStarted
- Rancast has:
  - only_allowed (address is in the list of participants, modifier during publish)
  - only_when_not_started

Start() / Initialize()

- Celo node registration done via "register(address user)"
- start() simply records startblock and starts DKG

- Randcast does node registration + startblock during initialize()
- Need to implement register logic here.

## Change #1: Register + Start -> Initialize

Need to write custom initialization code. (Block start logic is the same)

Args passed in as list of triplets (use struct?):

- ethereum address
- index of node within group (unused??)
- public key

Register logic must be included here.

- participants.push(each node eth address)
- keys[node address] = public key

## Change #2: custom -> Ownable

Use OpenZeppelin Ownable modifier