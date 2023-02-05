---
description: Description and functionalities
---

# PebbleDelegatee.sol

This contract allows relayers to interact with `Pebble.sol` on behalf of delegator users, to provide gas-less transaction services to them. There's provisions for an incentivizing fee for doing so.

{% hint style="info" %}
Relayers should try to check if a transaction would go smoothly and estimate gas required to relay a transaction, before going ahead with the actual relaying.

The incentive does not come into play if the transaction fails.
{% endhint %}

## Relaying

Anyone with a correctly signed message from a user can relay their transactions on their behalf, and earn a small fee.

Incentives are paid to relayers in the form of fees levied on a percentage of gas spent for transactions.

**To allow their transactions to be relayed, users need to deposit some funds** _(native blockchain currency)_ **in this contract. Gas spent by relayers is paid from this deposit, along with the above fee.  Deposits are withdrawable at any time.**

The fee is specified by basis points, and is changeable only by this contract's admin.

## Functions

### Change delegate fee

```solidity
/**
@dev Sets delegate fees (basis)
@param _delegateFeesBasisNew New delegate fees (basis) to set
 */
function setDelegateFeesBasis(
    uint16 _delegateFeesBasisNew
) external onlyPebbleDelegateeAdmins;
```

### Add funds _(for users)_

{% code overflow="wrap" %}
```solidity
function addFunds() external payable;
```
{% endcode %}

_Users can also deposit funds if they directly fund this contract's address._

### Withdraw funds _(for users & relayers)_

<pre class="language-solidity" data-overflow="wrap"><code class="lang-solidity">/**
@dev Withdraws all funds available for caller
*/
<strong>function withdrawFunds() external;
</strong></code></pre>

{% code overflow="wrap" %}
```solidity
/**
@dev Withdraws specified funds available for caller
@param _value Deposited value to withdraw
*/
function withdrawFunds(uint256 _value) external;
```
{% endcode %}

### Create group via delegation _(for relayers)_

{% code overflow="wrap" %}
```solidity
/**
@dev Creates a new group on behalf of delegator, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
@param _groupCreator Address of the group creator (Delegator in this case)
@param _groupParticipantsOtherThanCreator Array of group participants other than group creator
@param _initialPenultimateSharedKeyForCreatorX X coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
@param _initialPenultimateSharedKeyForCreatorY Y coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
@param _initialPenultimateSharedKeyFromCreatorX X coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
@param _initialPenultimateSharedKeyFromCreatorY Y coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
@param _groupCreatorDelegatorNonce Group creator's delegator nonce
@param _signatureFromDelegator Signature from delegator against which to confirm input params against
@return groupId New group's ID
 */
function createGroupForDelegator(
    address _groupCreator,
    address[] calldata _groupParticipantsOtherThanCreator,
    uint256 _initialPenultimateSharedKeyForCreatorX,
    uint256 _initialPenultimateSharedKeyForCreatorY,
    uint256 _initialPenultimateSharedKeyFromCreatorX,
    uint256 _initialPenultimateSharedKeyFromCreatorY,
    uint256 _groupCreatorDelegatorNonce,
    bytes calldata _signatureFromDelegator
) external delegateFor(_groupCreator) returns (uint256 groupId);
```
{% endcode %}

{% code overflow="wrap" %}
```solidity
/**
@dev Creates a new group on behalf of delegator, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
@param _groupCreator Address of the group creator (Delegator in this case)
@param _groupParticipantsOtherThanCreator Array of group participants other than group creator
@param _initialPenultimateSharedKeyForCreatorX X coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
@param _initialPenultimateSharedKeyForCreatorY Y coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
@param _initialPenultimateSharedKeyFromCreatorX X coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
@param _initialPenultimateSharedKeyFromCreatorY Y coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
@param _groupCreatorDelegatorNonce Group creator's delegator nonce
@param _signatureFromDelegator_v v component of signature from delegator against which to confirm input params against
@param _signatureFromDelegator_r v component of signature from delegator against which to confirm input params against
@param _signatureFromDelegator_s v component of signature from delegator against which to confirm input params against
@return groupId New group's ID
 */
function createGroupForDelegator(
    address _groupCreator,
    address[] calldata _groupParticipantsOtherThanCreator,
    uint256 _initialPenultimateSharedKeyForCreatorX,
    uint256 _initialPenultimateSharedKeyForCreatorY,
    uint256 _initialPenultimateSharedKeyFromCreatorX,
    uint256 _initialPenultimateSharedKeyFromCreatorY,
    uint256 _groupCreatorDelegatorNonce,
    uint8 _signatureFromDelegator_v,
    bytes32 _signatureFromDelegator_r,
    bytes32 _signatureFromDelegator_s
) external delegateFor(_groupCreator) returns (uint256 groupId);
```
{% endcode %}

### Accept invitation via delegation _(for relayers)_

{% code overflow="wrap" %}
```solidity
/**
@dev Accepts invititation to a group
@param _groupId Group id of the group to accept invite for
@param _groupParticipant Group participant who wants to accept group invite
@param _penultimateKeysFor Addresses for which updated penultimate shared keys are meant for
@param _penultimateKeysXUpdated Array of X coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
@param _penultimateKeysYUpdated Array of Y coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
@param _timestampForWhichUpdatedKeysAreMeant Timestamp at which the invitee checked the last updated penultimate keys
@param _groupParticipantDelegatorNonce Group participant's delegator nonce
@param _signatureFromGroupParticipant Signature from participant against which to confirm input params against
*/
function acceptGroupInviteForDelegator(
    uint256 _groupId,
    address _groupParticipant,
    address[] calldata _penultimateKeysFor,
    uint256[] calldata _penultimateKeysXUpdated,
    uint256[] calldata _penultimateKeysYUpdated,
    uint256 _timestampForWhichUpdatedKeysAreMeant,
    uint256 _groupParticipantDelegatorNonce,
    bytes calldata _signatureFromGroupParticipant
) external delegateFor(_groupParticipant);
```
{% endcode %}

{% code overflow="wrap" %}
```solidity
/**
@dev Accepts invititation to a group
@param _groupId Group id of the group to accept invite for
@param _groupParticipant Group participant who wants to accept group invite
@param _penultimateKeysFor Addresses for which updated penultimate shared keys are meant for
@param _penultimateKeysXUpdated Array of X coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
@param _penultimateKeysYUpdated Array of Y coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
@param _timestampForWhichUpdatedKeysAreMeant Timestamp at which the invitee checked the last updated penultimate keys
@param _groupParticipantDelegatorNonce Group participant's delegator nonce
@param _signatureFromGroupParticipant_v v component of signature from participant against which to confirm input params against
@param _signatureFromGroupParticipant_r r component of signature from participant against which to confirm input params against
@param _signatureFromGroupParticipant_s s component of signature from participant against which to confirm input params against
*/
function acceptGroupInviteForDelegator(
    uint256 _groupId,
    address _groupParticipant,
    address[] calldata _penultimateKeysFor,
    uint256[] calldata _penultimateKeysXUpdated,
    uint256[] calldata _penultimateKeysYUpdated,
    uint256 _timestampForWhichUpdatedKeysAreMeant,
    uint256 _groupParticipantDelegatorNonce,
    uint8 _signatureFromGroupParticipant_v,
    bytes32 _signatureFromGroupParticipant_r,
    bytes32 _signatureFromGroupParticipant_s
) external delegateFor(_groupParticipant);
```
{% endcode %}

### Send message via delegation _(for relayers)_

{% code overflow="wrap" %}
```solidity
/**
@dev Sends a message from Sender in a group
@param _groupId Group id of the group to send message in
@param _sender Sender who wants to send message
@param _encryptedMessage Encrypted message to send (MUST BE ENCRYPTED BY SHARED KEY, NOT PENULTIMATE SHARED KEY; SHARED KEY = SENDER PRIVATE KEY * SENDER PENULTIMATE SHARED KEY; THIS MUST BE CALCULATED LOCALLY)
@param _senderDelegatorNonce Sender's delegator nonce
@param _signatureFromSender Signature from sender against which to confirm input params against
 */
function sendMessageInGroupForDelegator(
    uint256 _groupId,
    address _sender,
    bytes calldata _encryptedMessage,
    uint256 _senderDelegatorNonce,
    bytes calldata _signatureFromSender
) external delegateFor(_sender);
```
{% endcode %}

{% code overflow="wrap" %}
```solidity
/**
@dev Sends a message from Sender in a group
@param _groupId Group id of the group to send message in
@param _sender Sender who wants to send message
@param _encryptedMessage Encrypted message to send (MUST BE ENCRYPTED BY SHARED KEY, NOT PENULTIMATE SHARED KEY; SHARED KEY = SENDER PRIVATE KEY * SENDER PENULTIMATE SHARED KEY; THIS MUST BE CALCULATED LOCALLY)
@param _senderDelegatorNonce Sender's delegator nonce
@param _signatureFromSender_v v component of signature from sender against which to confirm input params against
@param _signatureFromSender_r r component of signature from sender against which to confirm input params against
@param _signatureFromSender_s s component of signature from sender against which to confirm input params against
 */
function sendMessageInGroupForDelegator(
    uint256 _groupId,
    address _sender,
    bytes calldata _encryptedMessage,
    uint256 _senderDelegatorNonce,
    uint8 _signatureFromSender_v,
    bytes32 _signatureFromSender_r,
    bytes32 _signatureFromSender_s
) external delegateFor(_sender);
```
{% endcode %}
