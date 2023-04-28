import { Plugin } from "vue";
import { watchAccount, fetchSigner } from "@wagmi/core";
import usePebbleStore from "@store/pebble";
import { PebbleClient } from "@pebble/sdk";

const pebblePlugin: Plugin = {
    install(app, ...options) {
        const pebbleStore = usePebbleStore();

        watchAccount(async (account) => {
            if (account.isConnected) {
                pebbleStore.pebbleClient = new PebbleClient({
                    contracts: {
                        pebbleContractAddr: import.meta.env.VITE_PEBBLE_PROXY_ADDRESS
                    },
                    config: {
                        signer: await fetchSigner(),
                        blockConfirmations: parseInt(import.meta.env.VITE_BLOCK_CONFIRMATIONS),
                        graphQueryUrl: import.meta.env.VITE_SUBGRAPH_API_URL
                    }
                });

                // Start poller based on connect status
                pebbleStore.startPoller();
            } else {
                pebbleStore.pebbleClient = null;
            }
        });
    },
}

export default pebblePlugin;