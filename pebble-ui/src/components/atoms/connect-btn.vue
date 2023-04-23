<script setup lang="ts">
import { computed } from 'vue';
import useWalletStore from '@store/wallet';
import { disconnect } from "@wagmi/core";

// States
const walletStore = useWalletStore();
const isLoading = computed(() => walletStore.account?.isConnecting || walletStore.account?.isReconnecting);
const buttonText = computed(() => {
    switch (walletStore.account?.status) {
        case "connected":
            return `Connected: ${walletStore.account.address.slice(0, 7)}...`;
        case "connecting":
        case "reconnecting":
            return "Connecting";
        case "disconnected":
        default:
            return "Connect";
    }
});

// Methods
async function handleConnectBtnClick() {
    if (walletStore.account?.isDisconnected) {
        walletStore.web3Modal?.openModal();
    } else if (walletStore.account?.isConnected) {
        await disconnect();
    }
}
</script>

<template>
    <v-btn :loading="isLoading" @click.stop="handleConnectBtnClick" variant="elevated" prepend-icon="mdi-wallet-bifold-outline">
        {{ buttonText }}

        <template #loader>
            <v-progress-circular indeterminate size="20" width="3" class="mr-1"></v-progress-circular>
            <span>{{ buttonText }}</span>
        </template>
    </v-btn>
</template>

<style lang="scss" scoped></style>