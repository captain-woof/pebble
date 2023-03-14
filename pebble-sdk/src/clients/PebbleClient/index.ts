import { Contract, Signer, BigNumber } from "ethers";
import { IPebbleClient } from "types/clients/PebbleClient";
import { Pebble } from "types/pebble-contracts";
import { InviteEvent, AllInvitesAcceptedEvent, SendMessageEvent } from "types/pebble-contracts/Pebble";
import { abi as PEBBLE_ABI } from "abi/Pebble.json";
import { generateRandomPrivateKey, generateRandomNumber, getScalarProductWithGeneratorPoint, getScalarProductWithPoint, encryptMessageWithSharedKey, convertBase64ToHex } from "./utils";
import { Point } from "@noble/secp256k1";

export class PebbleClient {
    signer: Signer;
    pebbleContract: Pebble;
    blockConfirmations: number;

    // Constructor
    constructor({ config, contracts }: IPebbleClient) {
        this.signer = config.signer;
        this.blockConfirmations = config.blockConfirmations ?? 1;
        this.pebbleContract = new Contract(contracts.pebbleContractAddr, PEBBLE_ABI, this.signer) as Pebble;
    }

    /**
     * @dev Creates a group
     * @param groupParticipantsOtherThanCreator
     * @returns return.privateKeyCreator New private key of creator corresponding to the new group
     * @returns return.groupId Group Id of the newly formed group
     */
    async createGroup(groupParticipantsOtherThanCreator: Array<string>) {
        // Create creator params
        const privKeyCreator = generateRandomPrivateKey();
        const random = generateRandomNumber();

        // Penultimate shared keys for creator
        const initialPenultimateSharedKeyForCreator = getScalarProductWithGeneratorPoint(random);
        const { x: initialPenultimateSharedKeyForCreatorX, y: initialPenultimateSharedKeyForCreatorY } = initialPenultimateSharedKeyForCreator;

        // Penultimate shared keys from creator
        const initialPenultimateSharedKeyFromCreator = getScalarProductWithPoint(privKeyCreator, initialPenultimateSharedKeyForCreator);
        const { x: initialPenultimateSharedKeyFromCreatorX, y: initialPenultimateSharedKeyFromCreatorY } = initialPenultimateSharedKeyFromCreator;

        // Call contract and await transaction
        const tx = await this.pebbleContract.createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        const rcpt = await tx.wait(this.blockConfirmations);

        // Get group ID
        const eventInvite = (rcpt.events?.find(({ event }) => event === "Invite")) as InviteEvent;
        const groupId = eventInvite?.args?.groupId;
        if (!groupId || !groupId?._isBigNumber) {
            throw Error("Invalid group ID");
        }

        // Return params
        return {
            privateKeyCreator: BigNumber.from(privKeyCreator.toString()),
            groupId
        };
    }

    /**
     * @dev Gets all group participants in a Group other than signer
     * @param groupId Group id to check in
     * @return otherGroupParticipants Array of other group members' addresses
     */
    async getOtherGroupParticipants(groupId: BigNumber) {
        const otherGroupParticipants = await this.pebbleContract.getOtherGroupParticipants(groupId);
        return otherGroupParticipants;
    }

    /**
     * @dev Gets current penultimate shared keys for participants in a group
     * @param groupId Group ID to check in
     * @param participants Array of participants' addresses
     * @returns return.penultimateSharedKeysX Array of penultimate shared keys' X
     * @returns return.penultimateSharedKeysY Array of penultimate shared keys' Y
     */
    async getPenultimateSharedKeysFor(groupId: BigNumber, participants: Array<string>) {
        const { penultimateSharedKeysX, penultimateSharedKeysY } = await this.pebbleContract.getParticipantsGroupPenultimateSharedKey(groupId, participants);

        return {
            penultimateSharedKeysX, penultimateSharedKeysY
        };
    }

    /**
     * @dev Accepts invite to a group
     * @param groupId Group ID to accept invitation for
     * @returns return.privKeyParticipant Private key for participant corresponding to this group
     * @returns return.haveAllParticipantsAcceptedInvite True, if all participants have accepted group invite
     */
    async acceptInviteToGroup(groupId: BigNumber) {
        // Get other group participants
        const penultimateKeysFor = await this.getOtherGroupParticipants(groupId);

        // Generate private key
        const privKeyParticipant = generateRandomPrivateKey();

        // Get updated penultimate keys
        const { penultimateSharedKeysX, penultimateSharedKeysY } = await this.getPenultimateSharedKeysFor(groupId, penultimateKeysFor);
        const [penultimateSharedKeysXUpdated, penultimateSharedKeysYUpdated]: Array<Array<BigNumber>> = [[], []];

        for (let i = 0; i < penultimateSharedKeysX.length; i++) {
            const penultimateSharedKeyPoint = new Point(
                BigInt(penultimateSharedKeysX[i].toString()),
                BigInt(penultimateSharedKeysY[i].toString())
            );

            const { x, y } = getScalarProductWithPoint(
                BigInt(privKeyParticipant.toString()),
                penultimateSharedKeyPoint
            );
            penultimateSharedKeysXUpdated.push(BigNumber.from(x.toString()));
            penultimateSharedKeysYUpdated.push(BigNumber.from(y.toString()));
        }

        // Get timestamp at which above keys were fetched
        const timestampForWhichUpdatedKeysAreMeant = await this.pebbleContract.getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        // Do transaction
        const tx = await this.pebbleContract.acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateSharedKeysXUpdated,
            penultimateSharedKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        const rcpt = await tx.wait(this.blockConfirmations);

        // Check if all participants have accepted invites
        let haveAllParticipantsAcceptedInvite = false;
        const eventAllInvitesAcceptedEvent = (rcpt.events?.find(({ event }) => event === "AllInvitesAccepted")) as AllInvitesAcceptedEvent;
        const groupIdFromEvent = eventAllInvitesAcceptedEvent?.args?.groupId;
        if (groupIdFromEvent && groupIdFromEvent?._isBigNumber) {
            haveAllParticipantsAcceptedInvite = true;
        }

        // Return result
        return {
            privKeyParticipant: BigNumber.from(privKeyParticipant.toString()),
            haveAllParticipantsAcceptedInvite
        };
    }

    /**
     * @dev Calculates shared key for a participant in a group
     * @param groupId Group Id to calculate shared key for
     * @param participantPrivKey Participant's private key for this group
     * @returns Shared key
     */
    async calculateSharedKeyForGroup(groupId: BigNumber, participantPrivKey: BigNumber) {
        // Calculate shared key
        const { penultimateSharedKeyX, penultimateSharedKeyY } = await this.pebbleContract.getParticipantGroupPenultimateSharedKey(groupId, await this.signer.getAddress());
        const sharedKeyPoint = getScalarProductWithPoint(
            BigInt(participantPrivKey.toString()),
            new Point(
                BigInt(penultimateSharedKeyX.toString()),
                BigInt(penultimateSharedKeyY.toString())
            )
        );
        return BigNumber.from(sharedKeyPoint.x.toString());
    }

    /**
     * @dev Sends message from a group participant in a group
     * @param groupId Group id to send message in
     * @param message Message to send (plaintext)
     * @param sharedKey Shared key to use; use `calculateSharedKeyForGroup()` to pre-calculate this
     */
    async sendMessage(groupId: BigNumber, message: string, sharedKey: BigNumber) {
        // Encrypt message
        const messageEnc = encryptMessageWithSharedKey(message, BigInt(sharedKey.toString()));
        const messageEncHex = convertBase64ToHex(messageEnc);

        // Send message
        const tx = await this.pebbleContract.sendMessageInGroup(groupId, messageEncHex);
        const rcpt = await tx.wait(this.blockConfirmations);

        // Check if event was correctly fired
        const eventSendMessageEvent = (rcpt.events?.find(({ event }) => event === "SendMessage")) as SendMessageEvent;
        if (eventSendMessageEvent?.args?.encryptedMessage !== messageEncHex) {
            throw (Error("Incorrect message sent"));
        }

        return true;
    }
}
