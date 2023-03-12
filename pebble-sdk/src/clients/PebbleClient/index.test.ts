import { deployPebbleImplementation, deployPebbleProxy, signersTest } from "./utils-test";
import { Pebble } from "types/pebble-contracts/Pebble";
import { ContractFactory } from "ethers";
import PEBBLE from "abi/Pebble.json";
import { Pebble__factory } from "types/pebble-contracts/factories/Pebble__factory";
import { PebbleClient } from "./";

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

    it("Create group - Correct group IDs and Randomised creator private keys", async () => {
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
});