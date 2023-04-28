<script setup lang="ts">
import usePebbleStore from "@store/pebble";
import useToastStore from "@store/toast";
import { computed, ref } from "vue";

// States
const pebbleStore = usePebbleStore();
const toastStore = useToastStore();
const didAcceptGroupInvite = computed(() => pebbleStore.groupSelected?.didAcceptGroupInvite ?? false);
const isAcceptingInvite = ref(false);

// Methods
async function handleAcceptInvite() {
    try {
        isAcceptingInvite.value = true;
        await pebbleStore.acceptInvite();
    } catch {
        toastStore.showToast("Failed to accept invite!");
        isAcceptingInvite.value = false;
    } finally { }
}
</script>

<template>
    <div class="accept-invite pa-2 pa-sm-4">
        <!-- Waiting for everyone to accept invite -->
        <div v-if="didAcceptGroupInvite" class="accept-invite__waiting-for-everyone">
            <v-progress-circular indeterminate></v-progress-circular>
            <span class="text-body-1">
                Waiting for everyone else to accept their invites
            </span>
        </div>

        <!-- Your invite status -->
        <div v-else class="accept-invite__your-invite mt-6">
            <!-- Accept invite -->
            <v-btn class="accept-invite__your-invite__accept-btn" @click="handleAcceptInvite" :loading="isAcceptingInvite">
                Accept invite
            </v-btn>

            <!-- Extra message -->
            <span class="accept-invite__your-invite__extra-msg text-body-2 mt-2">
                {{ isAcceptingInvite ? "Accepting your invite" : "You need to accept your invite to start sending messages"
                }}
            </span>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.accept-invite {
    height: 100%;
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;

    .accept-invite__waiting-for-everyone {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    .accept-invite__your-invite {
        display: flex;
        flex-direction: column;
        align-items: center;
        width: 100%;

        .accept-invite__your-invite__accept-btn {
            display: flex;
        }

        .accept-invite__your-invite__extra-msg {
            max-width: 80%;
            text-align: center;
        }
    }
}
</style>