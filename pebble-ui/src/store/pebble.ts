import { PebbleClient } from "pebble-sdk";
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
    groupsSummary: null | Array<IGroupSummary>;
    groupSelected: null | IGroupSummary;
    groupSelectedSharedKey: null | bigint;
    poller: null | Poller;
    lastPollAtSecs: null | number; // Null = poll in progress
}

const defaultState: IPebbleStoreState = {
    pebbleClient: null,
    groupsSummary: null,
    groupSelected: null,
    groupSelectedSharedKey: null,
    poller: null,
    lastPollAtSecs: null
}

const usePebbleStore = defineStore("pebble", {
    state: (): IPebbleStoreState => defaultState,
    actions: {
        deselectGroupSelected() {
            this.groupSelected = null;
            this.groupSelectedSharedKey = null;
        },
        resetStore() {
            this.stopPoller();
            this.pebbleClient = null;
            this.groupsSummary = null;
            this.deselectGroupSelected();
            this.poller = null;
            this.lastPollAtSecs = null;
        },
        async createGroup(groupParticipantsOtherThanCreator: Array<string>) {
            if (this.pebbleClient) {
                const { groupId, privateKeyCreator } = await this.pebbleClient.createGroup(groupParticipantsOtherThanCreator);

                const walletStore = useWalletStore();
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
                const groupId = BigNumber.from(this.groupSelected?.id);
                const { privKeyParticipant } = await this.pebbleClient.acceptInviteToGroup(groupId);

                const walletStore = useWalletStore();
                setGroupInLocalStorage(walletStore.account?.address as string, groupId, privKeyParticipant);

                this.restartPoller();
            }
        },
        async sendMessage(messagePlaintext: string) {
            const walletStore = useWalletStore();

            if (this.pebbleClient && this.groupSelected && walletStore.account?.address && walletStore.account?.address.length > 0 && this.groupSelectedSharedKey) {
                await this.pebbleClient.sendMessage(
                    BigNumber.from(this.groupSelected.id),
                    messagePlaintext,
                    BigNumber.from(this.groupSelectedSharedKey)
                );

                this.restartPoller();
            }
        },
        async fetchGroupsSummary() {
            if (this.pebbleClient) {
                this.groupsSummary = (await this.pebbleClient.fetchGroupsSummary()).map((groupSummary) => ({
                    ...groupSummary,
                    detailsFetchedForFirstTime: false,
                    didAcceptGroupInvite: false
                }));
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
        async calculateSharedKeyForSelectedGroup() {
            const walletStore = useWalletStore();

            if (walletStore.account?.address && this.groupSelected?.id && this.pebbleClient) {
                const privateKeyForGroup = getGroupsFromLocalStorage(
                    walletStore.account.address
                )[this.groupSelected.id];

                if (privateKeyForGroup && privateKeyForGroup.length !== 0) {
                    this.groupSelectedSharedKey = BigInt((await this.pebbleClient.calculateSharedKeyForGroup(
                        BigNumber.from(this.groupSelected.id),
                        BigNumber.from(privateKeyForGroup)
                    )).toString());
                }
            }
        },
        startPoller() {
            this.stopPoller();

            this.poller = new Poller(
                30 * 1000,
                async () => {
                    const lastPollAtSecsPrev = this.lastPollAtSecs;

                    try {
                        this.lastPollAtSecs = null; // Poll start

                        await this.fetchGroupsSummary();

                        if (this.groupSelected) {
                            if (!this.groupSelectedSharedKey) {
                                await this.calculateSharedKeyForSelectedGroup();
                            }

                            await this.fetchGroupSelected();
                        }

                        this.lastPollAtSecs = Math.round(Date.now() / 1000); // Poll end   
                    } catch (error) {
                        this.lastPollAtSecs = lastPollAtSecsPrev; // Poll time undo
                    }
                }
            );
            this.poller.start(true);
        },
        restartPoller() {
            if (this.poller) {
                this.poller.restart();
            }
        },
        stopPoller() {
            if (this.poller) {
                this.poller.stop();
            }
        }
    }
});

export default usePebbleStore;