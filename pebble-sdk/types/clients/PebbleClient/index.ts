import { providers, Signer } from "ethers";

export interface IPebbleClient {
    contracts: {
        pebbleContractAddr: string;
    },
    config: {
        signer: Signer;
        blockConfirmations?: number;
        graphQueryUrl: string;
    }
}
