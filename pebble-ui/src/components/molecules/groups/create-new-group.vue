<script setup lang="ts">
import usePebbleStore from '@store/pebble';
import useToastStore from '@store/toast';
import useWalletStore from '@store/wallet';
import { ref } from 'vue';
import { utils } from 'ethers';

// States
const showCreateNewGroupDrawer = ref(false);
const participants = ref<Array<string>>([]);
const walletStore = useWalletStore();
const pebbleStore = usePebbleStore();
const toastStore = useToastStore();
const createGroupInProgress = ref(false);
const createGroupErrorMessage = ref("");

// Methods
function handleCreateNewGroupDrawerOpen() {
    showCreateNewGroupDrawer.value = !showCreateNewGroupDrawer.value;
}

function handleClear() {
    participants.value = [];
    createGroupErrorMessage.value = "";
}

async function handleCreateNewGroup() {
    createGroupInProgress.value = true;
    createGroupErrorMessage.value = "";

    // Validations
    let validationFailed = false;
    if (participants.value.length === 0) {
        createGroupErrorMessage.value = "Please enter the group participants";
        validationFailed = true;
    }
    if (participants.value.find((participant) => !utils.isAddress(participant))) {
        createGroupErrorMessage.value = "Please enter a valid address";
        validationFailed = true;
    }
    if (participants.value.find((participant) => participant === walletStore.account?.address)) {
        createGroupErrorMessage.value = "You cannot form a group with yourself";
        validationFailed = true;
    }
    if (validationFailed) {
        createGroupInProgress.value = false;
        return;
    };

    try {
        // Perform group creation
        const createGroupResult = await pebbleStore.createGroup(participants.value);

        // Reset values
        participants.value = [];
        showCreateNewGroupDrawer.value = false;

        // Show toast
        if (createGroupResult) {
            toastStore.showToast(`Group (id: ${createGroupResult.groupId.toString()}) created successfully!`);
        }
    } catch (error) {
        createGroupErrorMessage.value = "Could not create group!";
        console.error(error);
    } finally {
        createGroupInProgress.value = false;
    }
}
</script>

<template>
    <!-- Create new group button -->
    <v-btn @click="handleCreateNewGroupDrawerOpen" icon="mdi-plus" class="create-new-group-btn"></v-btn>

    <!-- Drawer -->
    <v-navigation-drawer v-model="showCreateNewGroupDrawer" tag="div" location="bottom" temporary
        class="create-new-group-drawer" :style="{ 'height': 'auto' }">
        <!-- Header -->
        <header class="d-flex align-center justify-space-between">
            <!-- Heading -->
            <h2 class="text-h5 pa-4">
                Create group
            </h2>

            <!-- Close button -->
            <v-btn @click="showCreateNewGroupDrawer = false" icon="mdi-close"></v-btn>
        </header>

        <v-divider></v-divider>

        <!-- Input for participants -->
        <v-combobox v-model="participants" class="pa-4" label="Participants to invite" chips multiple :scrim="false"
            clearable closable-chips prepend-inner-icon="mdi-account-multiple-plus-outline" focused
            :hint="`Addresses must be on ${walletStore.network?.name}`" :error="!!createGroupErrorMessage"
            :error-messages="createGroupErrorMessage" @click:clear="handleClear"></v-combobox>

        <!-- Button -->
        <v-btn class="d-flex ml-auto mx-4 my-6" @click="handleCreateNewGroup" append-icon="mdi-send-outline"
            :loading="createGroupInProgress">
            Create group
        </v-btn>
    </v-navigation-drawer>
</template>

<style lang="scss" scoped>
.create-new-group-btn {
    position: absolute;
    bottom: 20px;
    right: 20px;
}

.create-new-group-drawer {
    border-radius: 24px;
}
</style>