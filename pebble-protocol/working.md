---
description: How the protocol works internally
---

# Working

{% hint style="info" %}
This is intended to be a technical discussion about the protocol. Readers are assumed to have at least read the[#enters-pebble](introduction.md#enters-pebble "mention")section. Though, reading the whole [introduction.md](introduction.md "mention")is recommended.
{% endhint %}

## Penultimate keys

{% hint style="info" %}
Readers are supposed to know the basics of Elliptic curve and operations that can be done on them, to better understand what's happening under the hood.

Please read the series, [Elliptic Curve Cryptography: a gentle introduction](https://andrea.corbellini.name/2015/05/17/elliptic-curve-cryptography-a-gentle-introduction/), to form an idea.
{% endhint %}

In the [#enters-pebble](introduction.md#enters-pebble "mention")section, "fractional" keys were mentioned. The final stored "fractional" key is just one step away from being the complete shared secret key. Hence, this is called the penultimate key.

A slightly customised form of [Elliptic-curve Diffie-Hellman](https://en.wikipedia.org/wiki/Elliptic-curve\_Diffie%E2%80%93Hellman) (ECDH) is used to calculate and store penultimate keys necessary for each participant to independently (locally) arrive at the same shared secret key.

The [Secp256k1 curve](https://en.bitcoin.it/wiki/Secp256k1) is used for [elliptic curve point multiplication](https://en.wikipedia.org/wiki/Elliptic\_curve\_point\_multiplication), to "transform" a given initial number into another. This forms the "one-way" function, the results of which can be safely stored publicly without revealing the underlying secret (the initial number).

## Algorithm

The flow for the entire process can be divided up into 3 phases -

1. Creating group
2. Accepting invite to group
3. Sending messages to group

{% hint style="success" %}
**Each of the phases can be also delegated by a relayer**, instead of having the user execute these themselves.

Every function required to execute these has a counterpart delegate function.

See [PebbleDelegatee.sol](smart-contracts/pebbledelegatee.sol.md#relaying) to know more.
{% endhint %}

### Creating a group

These are the steps a user needs to do, to create a group.

1. Come up with a very large, random number, `RANDOM`. _(see_ [_FAQs_](faqs.md#what-is-the-need-for-the-large-random-number-while-deriving-the-initial-penultimate-shared-keys) _to know why)_
2. Perform `RANDOM * G`, and store this as "Initial Penultimate Shared Key For Creator".
3. Perform `Creator's private key * RANDOM * G`, and store this as "Initial Penultimate Shared Key From Creator".
4. Prepare a list of participants to invite into the room.
5. Call [`createGroup`](smart-contracts/pebble.sol.md#creating-a-group) with these parameters. [All chosen participants are sent invites](smart-contracts/#invite).

### Accepting invite to a group

This needs to be done by each invitee.

1. Get group ID of the group to join.
2. Prepare a list of all other group participants. _(see_ [_Get group participants from Id_](smart-contracts/pebble.sol.md#get-group-participants-from-group-id)_)_
3. Get existing penultimate keys for each of the above prepared group participants. _(see_ [_Get a group's penultimate shared keys_](smart-contracts/pebble.sol.md#gets-a-groups-penultimate-shared-keys-referred-to-as-fractional-keys-in-introduction-for-group-parti)_)_&#x20;
4. Perform a [point multiplication](https://en.wikipedia.org/wiki/Elliptic\_curve\_point\_multiplication) on each of these keys with the invitee's private key, and store as "Updated penultimate keys".
5. Get the timestamp when the penultimate keys (fetched in in Step 3) were last updated. (see [Get timestamp when a group's penultimate shared keys were last updated](smart-contracts/pebble.sol.md#gets-the-timestamp-when-a-groups-penultimate-shared-keys-referred-to-as-fractional-keys-in-introduct))
6. With parameters from Step 1, 2, 4 and 5, call [`acceptGroupInvite`](smart-contracts/pebble.sol.md#accepting-invitation-to-a-group). [All participants are notified when all invites are accepted](smart-contracts/#allinvitesaccepted).

### Sending messages to a group

Messages can be sent in a group only after every invitee has accepted their invite.

1. Fetch and store penultimate key for sender. _(see_ [_Get a sender's penultimate shared key_](smart-contracts/pebble.sol.md#gets-a-groups-penultimate-shared-keys-referred-to-as-fractional-keys-in-introduction-for-group-parti)_)_
2. Perform a [point multiplication](https://en.wikipedia.org/wiki/Elliptic\_curve\_point\_multiplication) on this key with the sender's private key, and store as "shared secret key". At this point, the key exchange is done.
3. Use shared secret key (from step 2) to symmetrically encrypt the intended message.
4. Call [`sendMessageInGroup`](smart-contracts/pebble.sol.md#sending-message-in-a-group) with parameters from step 3 to send a message. [All participants are notified of an incoming message.](smart-contracts/#sendmessage)

{% hint style="info" %}
The exact symmetric encryption algorithm to be used in step 3 is yet to be decided. Regardless, the parameters for the same would be derived from the shared secret key.

This ensures that everyone uses the same message encryption parameters and algorithm.
{% endhint %}

## Example

{% hint style="info" %}
While this example considers 3 group participants, the protocol can be used for any number of participants.
{% endhint %}

Let's consider 3 participants - Alice, Bob and Sam. Alice wants to create a group, and invite the other two in.

Let's consider the private keys of these people to be A/k, B/k and S/k.

### Alice creates a group

Alice performs all the steps as mentioned in [Creating a group](working.md#creating-a-group).&#x20;

After she's done, the penultimate keys look like this:

| Participant | Penultimate key    |
| ----------- | ------------------ |
| Alice       | RANDOM \* G        |
| Bob         | A/k \* RANDOM \* G |
| Sam         | A/k \* RANDOM \* G |

### Bob accepts the invitation

Bob performs all the steps as mentioned in [Accepting invite to a group](working.md#accepting-invite-to-a-group).

After he's done, the penultimate keys look like this:

| Participant | Penultimate key           |
| ----------- | ------------------------- |
| Alice       | B/k \* RANDOM \* G        |
| Bob         | A/k \* RANDOM \* G        |
| Sam         | B/k \* A/k \* RANDOM \* G |

### Sam accepts the invitation

Sam performs all the steps as mentioned in [Accepting invite to a group](working.md#accepting-invite-to-a-group).

After he's done, the final penultimate keys look like this:

| Participant | Penultimate key           |
| ----------- | ------------------------- |
| Alice       | S/k \* B/k \* RANDOM \* G |
| Bob         | S/k \* A/k \* RANDOM \* G |
| Sam         | B/k \* A/k \* RANDOM \* G |

### Sam wants to send a message

Observe how Sam's penultimate shared key is `B/k * A/k * RANDOM * G`.

When Sam's private key (S/k) is point multiplied with this, it creates the shared secret key `S/k * B/k * A/k * RANDOM * G`.

Having arrived at this, Sam can now use this shared secret to send a message as mentioned in [Sending messages to a group](working.md#sending-messages-to-a-group).

{% hint style="info" %}
Observe how we could've chosen any number of participants, any creator, and all participants would've still arrived at the same shared secret key.
{% endhint %}
