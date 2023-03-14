import { deployPebbleImplementation, deployPebbleProxy, signersTest } from "./utils-test";
import { Pebble } from "types/pebble-contracts/Pebble";
import { ContractFactory } from "ethers";
import PEBBLE from "abi/Pebble.json";
import { Pebble__factory } from "types/pebble-contracts/factories/Pebble__factory";
import { PebbleClient } from "./";
import { decryptMessageWithSharedKey, encryptMessageWithSharedKey } from "./utils";

/**
 * Runs tests for Pebble Client
 * 
 * Before running this, run a local blockchain:
 * anvil --gas-price 1
 */
describe("PebbleClient", () => {
    let pebbleContractImpl: Pebble;
    let pebbleContract: Pebble;

    beforeAll(async () => {
        // Deploy Pebble implementaion
        pebbleContractImpl = await deployPebbleImplementation();
    });

    beforeEach(async () => {
        // Deploy Pebble proxy
        pebbleContract = (new ContractFactory(PEBBLE.abi, PEBBLE.bytecode, signersTest[0]) as Pebble__factory)
            .attach((await deployPebbleProxy(pebbleContractImpl.address)).address);
    });

    it("Create group", async () => {
        // Create Pebble Client for group creator
        const groupCreatorSigner = signersTest[1];
        const pebbleClientGroupCreator = new PebbleClient({
            config: {
                signer: groupCreatorSigner
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });

        // Create group
        const groupParticipantsOtherThanCreatorSigners = signersTest.slice(2, 4);
        const { groupId: groupId1, privateKeyCreator: privateKeyCreator1 } = await pebbleClientGroupCreator.createGroup(
            groupParticipantsOtherThanCreatorSigners.map((groupParticipantsOtherThanCreatorSigner) => groupParticipantsOtherThanCreatorSigner.address)
        );

        // Create another group
        const { groupId: groupId2, privateKeyCreator: privateKeyCreator2 } = await pebbleClientGroupCreator.createGroup(
            groupParticipantsOtherThanCreatorSigners.map((groupParticipantsOtherThanCreatorSigner) => groupParticipantsOtherThanCreatorSigner.address)
        );

        // Test if first group ID is 0
        expect(groupId1.eq(0)).toEqual(true);

        // Test if second group ID is 1
        expect(groupId2.eq(1)).toEqual(true);

        // Test if private keys for creator are different
        expect(privateKeyCreator1.eq(privateKeyCreator2)).toEqual(false);
    });

    it("Accept group invite", async () => {
        // Create test group
        const groupCreatorSigner = signersTest[1];
        const pebbleClientGroupCreator = new PebbleClient({
            config: {
                signer: groupCreatorSigner
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        const groupParticipantsOtherThanCreatorSigners = signersTest.slice(2, 4);
        const { groupId, privateKeyCreator } = await pebbleClientGroupCreator.createGroup(
            groupParticipantsOtherThanCreatorSigners.map((groupParticipantsOtherThanCreatorSigner) => groupParticipantsOtherThanCreatorSigner.address)
        );

        // Accept invite - participant 1
        const pebbleClientGroupParticipant1 = new PebbleClient({
            config: {
                signer: groupParticipantsOtherThanCreatorSigners[0]
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        const { haveAllParticipantsAcceptedInvite: haveAllParticipantsAcceptedInvite1, privKeyParticipant: privKeyParticipant1 } = await pebbleClientGroupParticipant1.acceptInviteToGroup(groupId);

        // Accept invite - participant 2
        const pebbleClientGroupParticipant2 = new PebbleClient({
            config: {
                signer: groupParticipantsOtherThanCreatorSigners[1]
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        const { haveAllParticipantsAcceptedInvite: haveAllParticipantsAcceptedInvite2, privKeyParticipant: privKeyParticipant2 } = await pebbleClientGroupParticipant2.acceptInviteToGroup(groupId);

        // Test for private keys
        expect(privateKeyCreator.eq(privKeyParticipant1)).toEqual(false);
        expect(privKeyParticipant1.eq(privKeyParticipant2)).toEqual(false);

        // Test for all participants accepted invite
        expect(haveAllParticipantsAcceptedInvite1).toEqual(false);
        expect(haveAllParticipantsAcceptedInvite2).toEqual(true);
    });

    it("Shared key validity", async () => {
        // Create test group
        const groupCreatorSigner = signersTest[1];
        const pebbleClientGroupCreator = new PebbleClient({
            config: {
                signer: groupCreatorSigner
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        const groupParticipantsOtherThanCreatorSigners = signersTest.slice(2, 4);
        const { groupId, privateKeyCreator } = await pebbleClientGroupCreator.createGroup(
            groupParticipantsOtherThanCreatorSigners.map((groupParticipantsOtherThanCreatorSigner) => groupParticipantsOtherThanCreatorSigner.address)
        );

        // Accept invite - participant 1
        const pebbleClientGroupParticipant1 = new PebbleClient({
            config: {
                signer: groupParticipantsOtherThanCreatorSigners[0]
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        const { privKeyParticipant: privKeyParticipant1 } = await pebbleClientGroupParticipant1.acceptInviteToGroup(groupId);

        // Accept invite - participant 2
        const pebbleClientGroupParticipant2 = new PebbleClient({
            config: {
                signer: groupParticipantsOtherThanCreatorSigners[1]
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        const { privKeyParticipant: privKeyParticipant2 } = await pebbleClientGroupParticipant2.acceptInviteToGroup(groupId);

        // Calculate shared keys for all participants
        const sharedKeyGroupCreator = await pebbleClientGroupCreator.calculateSharedKeyForGroup(groupId, privateKeyCreator);
        const sharedKeyParticipant1 = await pebbleClientGroupParticipant1.calculateSharedKeyForGroup(groupId, privKeyParticipant1);
        const sharedKeyParticipant2 = await pebbleClientGroupParticipant2.calculateSharedKeyForGroup(groupId, privKeyParticipant2);

        // Encrypt message
        const message = "SOME PLAINTEXT MESSAGE";
        const messageEncGroupCreator = encryptMessageWithSharedKey(message, BigInt(sharedKeyGroupCreator.toString()));
        const messageEncGroupParticipant1 = encryptMessageWithSharedKey(message, BigInt(sharedKeyParticipant1.toString()));
        const messageEncGroupParticipant2 = encryptMessageWithSharedKey(message, BigInt(sharedKeyParticipant2.toString()));

        // Test if all shared keys are equal
        expect(sharedKeyGroupCreator.eq(sharedKeyParticipant1)).toEqual(true);
        expect(sharedKeyGroupCreator.eq(sharedKeyParticipant2)).toEqual(true);

        // Test decryption
        expect(
            decryptMessageWithSharedKey(messageEncGroupCreator, BigInt(sharedKeyGroupCreator.toString()))
        ).toEqual(message);
        expect(
            decryptMessageWithSharedKey(messageEncGroupCreator, BigInt(sharedKeyParticipant1.toString()))
        ).toEqual(message);
        expect(
            decryptMessageWithSharedKey(messageEncGroupCreator, BigInt(sharedKeyParticipant2.toString()))
        ).toEqual(message);

        expect(
            decryptMessageWithSharedKey(messageEncGroupParticipant1, BigInt(sharedKeyGroupCreator.toString()))
        ).toEqual(message);
        expect(
            decryptMessageWithSharedKey(messageEncGroupParticipant1, BigInt(sharedKeyParticipant1.toString()))
        ).toEqual(message);
        expect(
            decryptMessageWithSharedKey(messageEncGroupParticipant1, BigInt(sharedKeyParticipant2.toString()))
        ).toEqual(message);

        expect(
            decryptMessageWithSharedKey(messageEncGroupParticipant2, BigInt(sharedKeyGroupCreator.toString()))
        ).toEqual(message);
        expect(
            decryptMessageWithSharedKey(messageEncGroupParticipant2, BigInt(sharedKeyParticipant1.toString()))
        ).toEqual(message);
        expect(
            decryptMessageWithSharedKey(messageEncGroupParticipant2, BigInt(sharedKeyParticipant2.toString()))
        ).toEqual(message);
    });

    it("Send message", async () => {
        // Create test group
        const groupCreatorSigner = signersTest[1];
        const pebbleClientGroupCreator = new PebbleClient({
            config: {
                signer: groupCreatorSigner
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        const groupParticipantsOtherThanCreatorSigners = signersTest.slice(2, 4);
        const { groupId, privateKeyCreator } = await pebbleClientGroupCreator.createGroup(
            groupParticipantsOtherThanCreatorSigners.map((groupParticipantsOtherThanCreatorSigner) => groupParticipantsOtherThanCreatorSigner.address)
        );

        // Accept invite - participant 1
        const pebbleClientGroupParticipant1 = new PebbleClient({
            config: {
                signer: groupParticipantsOtherThanCreatorSigners[0]
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        await pebbleClientGroupParticipant1.acceptInviteToGroup(groupId);

        // Accept invite - participant 2
        const pebbleClientGroupParticipant2 = new PebbleClient({
            config: {
                signer: groupParticipantsOtherThanCreatorSigners[1]
            },
            contracts: {
                pebbleContractAddr: pebbleContract.address
            }
        });
        await pebbleClientGroupParticipant2.acceptInviteToGroup(groupId);

        // Calculate shared keys for group creator
        const sharedKeyGroupCreator = await pebbleClientGroupCreator.calculateSharedKeyForGroup(groupId, privateKeyCreator);

        // Send message
        const message = "SOME PLAINTEXT MESSAGE";
        await expect(pebbleClientGroupCreator.sendMessage(groupId, message, sharedKeyGroupCreator)).resolves.toBeTruthy();
    });
});