---
description: Smart contracts that make up the Pebble protocol
---

# Smart contracts

{% hint style="info" %}
The protocol's ecosystem (client-side apps) is a work in progress. Once things are ready, below contracts would be deployed, and their addresses would be mentioned here.
{% endhint %}

## Pebble contracts

{% hint style="success" %}
**All smart contracts for Pebble can be found in the repo under** [**/pebble-contracts**](https://github.com/captain-woof/pebble/tree/main/pebble-contracts)**.**
{% endhint %}

* **``**[**`Pebble.sol`**](pebble.sol.md) - The main contract with which users would interact. This is where groups are created, invites are sent & accepted, fractional keys are stored, and encrypted messages are sent.
* **``**[**`PebbleDelegatee.sol`**](pebbledelegatee.sol.md) - This allows relayers to interact with `Pebble.sol` on behalf of delegator users, to provide gas-less transaction services to them. There's provisions for an incentivizing  fee for doing so.

### Deployments

| Contracts                                | Address        |
| ---------------------------------------- | -------------- |
| **PebbleProxy.sol** _(proxy)_            | To be deployed |
| **Pebble.sol** _(implementation)_        | To be deployed |
| **PebbleDelegatee.sol** _(for relayers)_ | To be deployed |

## Events

Throughout the lifecycle of a group, all the way from its creation to its participants sending messages in the group, certain events are emitted.

### Invite

When an invite is sent, this event is emitted for each invited participant:

<pre class="language-solidity" data-overflow="wrap"><code class="lang-solidity">```
event Invite(
<strong>   uint256 indexed groupId,
</strong>   address indexed creator,
   address indexed participant
 );
```
</code></pre>

### AllInvitesAccepted

When all participants of a group have accepted their invites, this event is emitted once:

{% code overflow="wrap" %}
```solidity
event AllInvitesAccepted(uint256 indexed groupId);
```
{% endcode %}

### SendMessage

When a message is sent by a group participant in a group, this event is emitted once per message:

{% code overflow="wrap" %}
```solidity
event SendMessage(
    uint256 indexed groupId,
    address indexed sender,
    bytes encryptedMessage
);
```
{% endcode %}

## Running tests

Tests are written in Foundry. To run the tests, execute:

```bash
forge test --via-ir --gas-price 1 -vvv
```
