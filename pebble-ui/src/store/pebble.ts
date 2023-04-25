import { PebbleClient } from "@pebble/sdk";
import { defineStore } from "pinia";
import { BigNumber } from "ethers";
import useWalletStore from "./wallet";
import { getGroupsFromLocalStorage, setGroupInLocalStorage } from "@utils/localStorage";
import { Poller } from "@utils/poller";

export interface IGroupSummary {
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
    detailsFetchedForFirstTime: boolean;
    didAcceptGroupInvite: boolean;
}

export interface IPebbleStoreState {
    pebbleClient: null | PebbleClient;
    groupsSummary: Array<IGroupSummary>;
    groupSelected: null | IGroupSummary;
    poller: null | Poller
}

const usePebbleStore = defineStore("pebble", {
    state: (): IPebbleStoreState => ({
        pebbleClient: null,
        groupsSummary: [],
        groupSelected: null,
        poller: null
    }),
    actions: {
        async createGroup(groupParticipantsOtherThanCreator: Array<string>) {
            if (this.pebbleClient) {
                const walletStore = useWalletStore();
                const { groupId, privateKeyCreator } = await this.pebbleClient.createGroup(groupParticipantsOtherThanCreator);

                setGroupInLocalStorage(walletStore.account?.address as string, groupId, privateKeyCreator);
                this.restartPoller();

                return {
                    groupId,
                    privateKeyCreator
                }
            }
        },
        async acceptInvite() {
            if (this.pebbleClient) {
                await this.pebbleClient.acceptInviteToGroup(BigNumber.from(this.groupSelected?.id));
                this.restartPoller();
            }
        },
        async fetchGroupsSummary() {
            if (this.pebbleClient) {
                this.groupsSummary = await this.pebbleClient.fetchGroupsSummary();
            }
        },
        async fetchGroupSelected() {
            if (this.pebbleClient && this.groupSelected?.id) {
                // Push necessary promises to resolve
                const promises: Array<Promise<any>> = [];
                promises.push(this.pebbleClient.fetchGroup(BigNumber.from(this.groupSelected.id)));
                if (!this.groupSelected?.allInvitesAccepted && !this.groupSelected.didAcceptGroupInvite) {
                    promises.push((async () => ({
                        didAcceptGroupInvite: await this.pebbleClient?.didAcceptGroupInvite(BigNumber.from(this.groupSelected?.id)) ?? false
                    }))());
                }

                // Resolve and combine results
                const results = await Promise.all(promises);
                const resultObj = results.reduce((obj, result) => ({ ...obj, ...result }), {});
                this.groupSelected = {
                    ...this.groupSelected,
                    ...resultObj,
                    detailsFetchedForFirstTime: true
                };
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

                    if (this.groupSelected) {
                        await this.fetchGroupSelected();
                    }
                }
            );
            this.poller.start(true);
        },
        restartPoller() {
            if (this.poller) {
                this.poller.restart();
            }
        }
    }
});

export default usePebbleStore;