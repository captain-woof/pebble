---
description: Description and functionalities
---

# Pebble.sol

The main contract with which users would interact. This is where groups are created, invites are sent & accepted, fractional keys are stored, and encrypted messages are sent.

This is deployed behind an upgradeable proxy.

## Modules

**This core contract is made up of a few modules, each of which adds a suite of functionalities needed for the protocol.**

These modules store the data they need at particular slots, providing abstracted internal helpers to Pebble.

**These are the modules:**

* _PebbleRoleManager_
* _PebbleImplementationManager_
* _PebbleSignManager_
* _PebbleDelagateVerificationManager_
* _PebbleGroupManager_

### PebbleRoleManager

This is responsible for adding role-bases access functionalities for the Pebble contract. It allows granting, revoking, and checking of roles.

Roles managed:

1. `PEBBLE_ADMIN_ROLE` - The "super-admin", with authority to deploy [PebbleDelegatees](pebble.sol.md#pebbledelegatee.sol), change delegation fees, upgrade the proxy, and so on.
2. `PEBBLE_DELEGATEE_ROLE` - Meant for [PebbleDelegatees](pebble.sol.md#pebbledelegatee.sol) authorised to be used by relayers acting on behalf of users.&#x20;

### PebbleImplementationManager

Controls who can upgrade the proxy, by overriding `_authorizeUpgrade` in `UUPSUpgradeable`.

### PebbleSignManager

Controls `EIP712Upgradeable` params, which are then used by users to sign meta-transactions for relayers.

* **Name**: `"PEBBLE"`
* **Version**: Call `getVersion()` to always get the updated version.

### PebbleDelagateVerificationManager

Responsible for managing a delegator's nonce, and provides a way to read the next available nonce.

All internal functions, that consume a nonce, increments it.

#### **Get a delegator's next available nonce (to be used in signing meta-transactions):**

{% code overflow="wrap" %}
```solidity
/**
@dev Gets a delegator's next allowed nonce
@dev Delegators must use this to sign anything
@param _delegator Address of delegator
@return nonce Delegator's allowed nonce
 */
function getDelegatorNonce(address _delegator)
    external
    view
    returns (uint256 nonce);
```
{% endcode %}

### PebbleGroupManager

Provides functions for group functionalities - creating groups, accepting invites to groups and sending messages in group.

#### **Creating a group:**

{% code overflow="wrap" %}
```solidity
/**
@dev Creates a new group, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
@param _groupParticipantsOtherThanCreator Array of group participants other than group creator
@param _initialPenultimateSharedKeyForCreatorX X coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
@param _initialPenultimateSharedKeyForCreatorY Y coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
@param _initialPenultimateSharedKeyFromCreatorX X coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
@param _initialPenultimateSharedKeyFromCreatorY Y coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
@return groupId New group's ID
*/
function createGroup(
    address[] calldata _groupParticipantsOtherThanCreator,
    uint256 _initialPenultimateSharedKeyForCreatorX,
    uint256 _initialPenultimateSharedKeyForCreatorY,
    uint256 _initialPenultimateSharedKeyFromCreatorX,
    uint256 _initialPenultimateSharedKeyFromCreatorY
) external returns (uint256 groupId);
```
{% endcode %}

#### **Creating a group with delegation **_**(callable by PebbleDelegatee contract only)**_**:**

<pre class="language-solidity" data-overflow="wrap"><code class="lang-solidity">/**
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
)
<strong>    external
</strong>    onlyPebbleDelegatee
    delegatorNonceCorrect(_groupCreator, _groupCreatorDelegatorNonce)
    returns (uint256 groupId);
</code></pre>

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
@param _signatureFromDelegator_r r component of signature from delegator against which to confirm input params against
@param _signatureFromDelegator_s s component of signature from delegator against which to confirm input params against
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
)
    external
    onlyPebbleDelegatee
    delegatorNonceCorrect(_groupCreator, _groupCreatorDelegatorNonce)
    returns (uint256 groupId);
```
{% endcode %}

#### **Accepting invitation to a group:**

{% code overflow="wrap" %}
```solidity
/**
@dev Accepts invititation to a group
@param _groupId Group id of the group to accept invite for
@param _penultimateKeysFor Addresses for which updated penultimate shared keys are meant for
@param _penultimateKeysXUpdated Array of X coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
@param _penultimateKeysYUpdated Array of Y coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
@param _timestampForWhichUpdatedKeysAreMeant Timestamp at which the invitee checked the last updated penultimate keys
*/
function acceptGroupInvite(
    uint256 _groupId,
    address[] calldata _penultimateKeysFor,
    uint256[] calldata _penultimateKeysXUpdated,
    uint256[] calldata _penultimateKeysYUpdated,
    uint256 _timestampForWhichUpdatedKeysAreMeant
);
```
{% endcode %}

#### **Accepting invitation to a group via delegation **_**(callable by PebbleDelegatee contract only)**_**:**

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
)
    external
    onlyPebbleDelegatee
    delegatorNonceCorrect(
        _groupParticipant,
        _groupParticipantDelegatorNonce
    );
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
)
    external
    onlyPebbleDelegatee
    delegatorNonceCorrect(
        _groupParticipant,
        _groupParticipantDelegatorNonce
    );
```
{% endcode %}

#### **Sending message in a group:**

{% code overflow="wrap" %}
```solidity
/**
@dev Sends a message from Sender in a group
@param _groupId Group id of the group to send message in
@param _encryptedMessage Encrypted message to send (MUST BE ENCRYPTED BY SHARED KEY, NOT PENULTIMATE SHARED KEY; SHARED KEY = SENDER PRIVATE KEY * SENDER PENULTIMATE SHARED KEY; THIS MUST BE CALCULATED LOCALLY)
 */
function sendMessageInGroup(
    uint256 _groupId,
    bytes calldata _encryptedMessage
) external;
```
{% endcode %}

#### **Sending message in a group with delegation** _(callable by PebbleDelegatee contract only)_**:**

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
)
    external
    onlyPebbleDelegatee
    delegatorNonceCorrect(_sender, _senderDelegatorNonce);
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
)
    external
    onlyPebbleDelegatee
    delegatorNonceCorrect(_sender, _senderDelegatorNonce);
```
{% endcode %}

#### **Get group participants from group ID:**

{% code overflow="wrap" %}
```solidity
/**
@dev Searches through group and finds all other group participants (excluding the participant who's invoking this)
@param _groupId Group id of the group
@return otherParticipants Array of other group participants
 */
function getOtherGroupParticipants(
    uint256 _groupId
) external view returns (address[] memory otherParticipants);
```
{% endcode %}

#### **Gets the timestamp when a group's penultimate shared keys** _(referred to as "fractional" keys in_ [_Introduction_](../introduction.md)_)_ **was last updated:**

{% code overflow="wrap" %}
```solidity
/**
@dev Gets timestamp when a group's penultimate shared keys were last updated
@param _groupId Group id of the group
@return timestamp Timestamp when a group's penultimate shared keys were last updated
 */
function getGroupPenultimateSharedKeyLastUpdateTimestamp(
    uint256 _groupId
) external view returns (uint256 timestamp);
```
{% endcode %}

#### **Gets a group's penultimate shared keys**  _(referred to as "fractional" keys in_ [_Introduction_](../introduction.md)_)_ **for group participants:**

{% code overflow="wrap" %}
```solidity
/**
@dev Gets a participant's penultimate shared key for a group id
@param _groupId Group id to use to fetch penultimate shared key
@param _groupParticipant Group participant for whom to fetch the penultimate shared key
@return penultimateSharedKeyX X coordinate of penultimate shared key of group participant; Participant 1 * Participant 2 ... * RANDOM * G
@return penultimateSharedKeyY Y coordinate of penultimate shared key of group participant; Participant 1 * Participant 2 ... * RANDOM * G
 */
function getParticipantGroupPenultimateSharedKey(
    uint256 _groupId,
    address _groupParticipant
)
    external
    view
    returns (uint256 penultimateSharedKeyX, uint256 penultimateSharedKeyY);
```
{% endcode %}

{% code overflow="wrap" %}
```solidity
/**
@dev Gets a participant's penultimate shared key for a group id
@param _groupId Group id to use to fetch penultimate shared key
@param _groupParticipants Array of group participants for whom to fetch the penultimate shared keys
@return penultimateSharedKeysX Array of X coordinate of penultimate shared keys of group participants; Participant 1 * Participant 2 ... * RANDOM * G
@return penultimateSharedKeysY Array of Y coordinate of penultimate shared keys of group participants; Participant 1 * Participant 2 ... * RANDOM * G
 */
function getParticipantsGroupPenultimateSharedKey(
    uint256 _groupId,
    address[] memory _groupParticipants
)
    external
    view
    returns (
        uint256[] memory penultimateSharedKeysX,
        uint256[] memory penultimateSharedKeysY
    );
```
{% endcode %}

#### **Check if a participant accepted a group invite:**

```solidity
/**
* @dev Returns `true` if a participant has accepted a group invite
* @param _groupId Group id of the group to check in
 * @param _participant Participant whose acceptance is to be checked
 */
function didParticipantAcceptGroupInvite(
    uint256 _groupId,
    address _participant
) external view returns (bool);
```
