---
description: A brief introduction to the Pebble protocol
---

# Introduction

{% hint style="info" %}
This page is intended to be more of a non-technical discussion on the protocol. To know the actual working, read [Working](working.md).
{% endhint %}

**Pebble started off with the aim of allowing multiple users to send messages to each other, in a format that was indecipherable to anyone but themselves.**

The core of the protocol, thus, had to be a key-exchange mechanism. **Conventional mechanisms require everyone, who wants to form a messaging group, to come up with the same secret key.** This is done by taking "a fraction of" the key from each user, and combining them to arrive at the correct, complete key.

They would then use this secret key to encrypt all their messages, ensuring no else can read them.

## But there's a problem...

**There is a problem with conventional mechanisms - they all require every user to participate in the key-exchange at the same time!**

Imagine how annoying it'd be if you could only send a message to someone if they're online. The problem would scale up exponentially as you increase the number of group participants.

Something was needed to bridge the gap, securely.

## Coming up with a solution

The obvious solution to the above problem would be - **instead of having all users come up with and share their "fraction" of the key at the same time, they would just store their fractional keys securely at one spot**, and only when everyone else had submitted their "fraction"s, they would just read off the result.

To give users the assurance that no one would interfere in this exchange (and thus become co-owners of the key), **this "one spot" of fractional keys cannot be a centralised server - it needs to be a spot on a blockchain**. This way, all interactions are public.

> But wait a minute! If our keys are on the blockchain itself, doesn't that mean anyone can read them?

Very astute observation. They absolutely can. Therefore, **there needs to be a way such that even when anyone else can read these fractional keys, it would still be of no use to them.**

A way of ensuring this, is to make sure none of the stored fractional keys can be combined to create the final secret key.

> But wait. Wasn't "combining fractional keys to create one single shared secret key" the very requirement?

It was indeed. This would've been a paradox, if not for Pebble.

## Enters Pebble

**Briefly, what Pebble does, is store all the fractional keys except for one of them. That one is never revealed, never stored, never known, and yet can be usable.**

A customised form of [Elliptic-curve Diffie-Hellman](https://en.wikipedia.org/wiki/Elliptic-curve\_Diffie%E2%80%93Hellman) (ECDH) is used to achieve this.

{% hint style="info" %}
If you don't know what public key cryptography is, you should watch this quick video before proceeding:

[Public key cryptography: What is it? | Computer Science | Khan Academy](https://www.youtube.com/watch?v=MsqqpO9R5Hc)
{% endhint %}

Pebble requires a group participant to decide on a private key (which is never shared) and a chosen number. This chosen number is then passed through a "one-way" function, and shared with the second participant.

The second participant then performs the same "one-way" function on the number with their private key, and then shares the result with the third participant.

This continues on with all participants, until everyone has done it.

At last, the first participant would take this shared number, and perform the "one-way" function with their private key, and arrive at the final key on their own side, never revealing it to others.

**Here's an example with 3 participants** - Alice, Bob and Sam. Let's assume <mark style="background-color:blue;">A/k</mark>, <mark style="background-color:red;">B/k</mark> and <mark style="background-color:orange;">S/k</mark> to be their private keys. Let's assume a one-way function, using which getting <mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark> from <mark style="background-color:green;">N</mark> and <mark style="background-color:red;">B/k</mark> is very easy, but getting <mark style="background-color:green;">N</mark> and <mark style="background-color:red;">B/k</mark> from <mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark> is practically impossible.

<table data-view="cards"><thead><tr><th></th><th></th><th></th></tr></thead><tbody><tr><td><strong>1.</strong></td><td>Alice comes up with a number <mark style="background-color:green;">N</mark>, and sends it to Bob.</td><td><em><mark style="background-color:green;">N</mark> is a fractional key, as it is not complete.</em></td></tr><tr><td><strong>2.</strong></td><td>Bob takes <mark style="background-color:green;">N</mark>, performs the "one-way" function with <mark style="background-color:red;">B/k</mark>, and sends result <mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark> to Sam.</td><td><em><mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark> is a fractional key.</em></td></tr><tr><td><strong>3.</strong></td><td>Sam takes <mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark>, performs the "one-way" function with <mark style="background-color:orange;">S/k</mark>, and sends result <mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark>.<mark style="background-color:orange;">S/k</mark> to Alice.</td><td><em><mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark>.<mark style="background-color:orange;">S/k</mark> is a fractional key.</em></td></tr><tr><td><strong>4.</strong></td><td>Alice takes <mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark>.<mark style="background-color:orange;">S/k</mark>, performs the "one-way" function on it with <mark style="background-color:blue;">A/k</mark>, and calculates <mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark>.<mark style="background-color:orange;">S/k</mark>.<mark style="background-color:blue;">A/k</mark></td><td><em><mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark>.<mark style="background-color:orange;">S/k</mark>.<mark style="background-color:blue;">A/k</mark> is now the complete key. This is stored locally.</em></td></tr><tr><td><strong>5.</strong></td><td><mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark>.<mark style="background-color:orange;">S/k</mark>.<mark style="background-color:blue;">A/k</mark> now becomes the shared secret key Alice would use to encrypt her messages.</td><td><em>Notice how the shared fractional keys never revealed any secret.</em></td></tr></tbody></table>

**Notice how we could do the same for both Bob and Sam**, and arrive at the same <mark style="background-color:green;">N</mark>.<mark style="background-color:red;">B/k</mark>.<mark style="background-color:orange;">S/k</mark>.<mark style="background-color:blue;">A/k</mark> _(might be jumbled up, but the result would be the same)._

This is exactly what Pebble protocol does - help people like Alice, Bob and Sam to store their fractional keys, so that others can use it later, whenever they'd be available, to continue the chain and pass on the fractional keys to the next participant.

Once the fractional keys are ready, any participant can derive the complete key, and use it to encrypt/decrypt their and each other's messages.&#x20;

{% hint style="info" %}
If you have questions, please read the [FAQs](faqs.md).
{% endhint %}
