import { Contract, Signer, BigNumber } from "ethers";
import { IPebbleClient } from "types/clients/PebbleClient";
import { Pebble } from "types/pebble-contracts";
import { InviteEvent } from "types/pebble-contracts/Pebble";
import PEBBLE_INTERFACE from "abi/Pebble.json";
import { generateRandomPrivateKey, generateRandomNumber, getScalarProductWithGeneratorPoint, getScalarProductWithPoint } from "./utils";

export class PebbleClient {
    signer: Signer;
    pebbleContract: Pebble;

    // Constructor
    constructor({ config, contracts }: IPebbleClient) {
        this.signer = config.signer;
        this.pebbleContract = new Contract(contracts.pebbleContractAddr, PEBBLE_INTERFACE.abi, this.signer) as Pebble;
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
        const rcpt = await tx.wait();

        // Get group ID
        const eventInvite = (rcpt.events?.find(({ event }) => event === "Invite")) as InviteEvent;
        const groupId = eventInvite?.args?.groupId;
        if (!groupId || !groupId?._isBigNumber) {
            throw Error("Invalid group ID");
        }

        // Return params
        return {
            privateKeyCreator: BigNumber.from(privKeyCreator),
            groupId
        };
    }
}
