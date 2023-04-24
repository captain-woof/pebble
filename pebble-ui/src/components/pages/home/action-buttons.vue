<script setup lang="ts">
import useWalletStore from '@store/wallet';
import { useRouter } from 'vue-router';

// States
const walletStore = useWalletStore();
const router = useRouter();

// Methods
async function handleGetStarted() {
    // Redirect if connected
    if (walletStore.account?.isConnected) {
        await router.push({ name: "groups" });
    } else {
        await walletStore.web3Modal?.openModal();
    }
}
</script>

<template>
    <div class="action-btns mt-6">
        <!-- Learn more -->
        <a href="https://captain-woof.gitbook.io/pebble-protocol/" target="_blank">
            <v-btn prepend-icon="mdi-book-open">
                Learn more
            </v-btn>
        </a>

        <!-- Get started -->
        <v-btn class="ml-sm-2" append-icon="mdi-send-variant" @click.stop="handleGetStarted">
            Get started
        </v-btn>
    </div>
</template>

<style lang="scss" scoped>
.action-btns {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;

    &>* {
        min-width: 160px;
    }
}

a {
    text-decoration: none;
    color: unset;
}
</style>