---
description: Answering questions a reader might have about the Protocol
---

# FAQs

## Does any participant need to send their private keys directly?

Absolutely never!

If you read the [Working](working.md) page, you'd know that all the participants ever send, are the point multiplication products of their private keys and some large number.

Read [Penultimate Keys](working.md#penultimate-keys) to know how this product would never reveal the private key.

## What is the need for the "large random number" while deriving the initial penultimate shared keys?

Assume we proceeded without this. Let's say a group of 4 participants decided to form a group, and the key exchange is complete.

The penultimate shared key for Participant no. 4 would be `P1/k * P2/k * P3/k * G`. This would be readable by Participant no. 4 of course.

Next, assume Participants 1, 2 and 3 decided to make a group of their own, keeping 4 out. What would be the shared secret key for this new group? It would be `P1/k * P2/k * P3/k * G` . Isn't this the same as what Participant no. 4 would know from the previous group?

This is the significance of the large random number during derivation of the initial penultimate key. If used, the penultimate shared key for Participant 4 would have been `N1 * P1/k * P2/k * P3/k * G,` which would be very different (and thus unknown) than the shared secret key `N2 * P1/k * P2/k * P3/k * G` of the next room.

## What happens if the same participants want to form another group?

They would succeed, since the same group number is never repeated.

Messages in the previous group would remain intact. The new group will start out with no messages.

## How to remove a participant?

Since all participants together form the shared secret key, there's no point in removing a participant - they can anyways calculate the shared secret key themselves and decipher all messages.

Instead, it is recommended to just create another room.

## Who can read a group's messages?

Since the shared secret key can only be derived by the owners of the private keys that formed the penultimate shared keys, only those owners can decipher and read those messages.

To everyone else, all your messages would appear garbled.

## So, how will non tech-savvy users use Pebble?

Pebble is not at all intended to be used just by tech-savvy people via direct smart contract interaction.

It's meant to be used just like any other Messaging app.

For this, **we are in the progress of developing our own Messaging app that leverages Pebble, and does the heavy-lifting for you**. Once made, this documentation would be updated to reflect the same.&#x20;
