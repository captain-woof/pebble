import { PebbleClient } from "@pebble/sdk";
import { defineStore } from "pinia";
import { BigNumber } from "ethers";
import useWalletStore from "./wallet";
import { getGroupsFromLocalStorage, setGroupInLocalStorage } from "@utils/localStorage";
import { Poller } from "@utils/poller";

export interface IPebbleStoreState {
    pebbleClient: null | PebbleClient;
    groupsSummary: Array<{
        id: string;
        creator: string;
        allInvitesAccepted: boolean;
        participants: Array<{
            invitee: string;
        }>;
        messages: Array<{
            id: string;
            messageEnc: string;
            sender: string;
            timestamp: string
        }>;
    }>;
    poller: null | Poller
}

const usePebbleStore = defineStore("pebble", {
    state: (): IPebbleStoreState => ({
        pebbleClient: null,
        groupsSummary: [],
        poller: null
    }),
    actions: {
        async createGroup(groupParticipantsOtherThanCreator: Array<string>) {
            if (this.pebbleClient) {
                const walletStore = useWalletStore();
                const { groupId, privateKeyCreator } = await this.pebbleClient.createGroup(groupParticipantsOtherThanCreator);

                setGroupInLocalStorage(walletStore.account?.address as string, groupId, privateKeyCreator);
                await this.restartPoller();

                return {
                    groupId,
                    privateKeyCreator
                }
            }
        },
        async fetchGroupsSummary() {
            if (this.pebbleClient) {
                this.groupsSummary = await this.pebbleClient.fetchGroupsSummary();
            }
        },
        async startPoller() {
            if (this.poller) {
                this.poller.stop();
            }

            this.poller = new Poller(
                45 * 1000,
                async () => {
                    await this.fetchGroupsSummary();
                }
            );
            this.poller.start(true);
        },
        async restartPoller() {
            if (this.poller) {
                this.poller.restart();
            }
        }
    }
});

export default usePebbleStore;