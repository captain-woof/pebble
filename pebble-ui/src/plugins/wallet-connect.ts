import { Plugin } from "vue";
import { EthereumClient, w3mConnectors, w3mProvider } from '@web3modal/ethereum';
import { Web3Modal } from '@web3modal/html';
import { configureChains, createClient, watchAccount, watchNetwork } from '@wagmi/core';
import { polygonMumbai } from '@wagmi/core/chains';
import useWalletStore from "@store/wallet";
import { Router } from "vue-router";

const WalletConnectPlugin: Plugin = {
    install(app, ...options: [Router]) {
        // Constants
        const walletStore = useWalletStore();
        const router = options[0];

        // Create Web3Modal
        const chains = [polygonMumbai]
        const projectId = import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID;

        const { provider } = configureChains(chains, [w3mProvider({ projectId })])
        const wagmiClient = createClient({
            autoConnect: true,
            connectors: w3mConnectors({ projectId, version: 2, chains }),
            provider
        });
        const ethereumClient = new EthereumClient(wagmiClient, chains);
        const web3Modal = new Web3Modal({
            projectId,
            defaultChain: polygonMumbai,
            themeVariables: {
                '--w3m-font-family': "'DM Sans', sans-serif",
            },
            themeMode: "dark"
        },
            ethereumClient);
        walletStore.web3Modal = web3Modal;

        // Setup listeners
        watchNetwork((network) => {
            walletStore.network = network.chain ?? null;
        });

        watchAccount(async (account) => {
            walletStore.account = account;

            // Redirect based on connect status
            if (account.isConnected) {
                await router.push({ name: "groups" });
            } else {
                await router.push({ name: "home" });
            }
        });
    },
}

export default WalletConnectPlugin;