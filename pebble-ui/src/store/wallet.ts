import { Chain, GetAccountResult, Provider } from "@wagmi/core";
import { Web3Modal } from "@web3modal/html";
import { defineStore } from "pinia";

export interface IWalletStoreState {
    web3Modal: null | Web3Modal;
    network: null | Chain;
    account: null | GetAccountResult<Provider>;
}

const useWalletStore = defineStore("wallet", {
    state: (): IWalletStoreState => ({
        web3Modal: null,
        network: null,
        account: null
    })
});

export default useWalletStore;