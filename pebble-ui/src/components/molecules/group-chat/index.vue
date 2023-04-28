<script setup lang="ts">
import { useRoute } from "vue-router";
import { computed, watch } from "vue";
import usePebbleStore from "@store/pebble";
import Loader from "@components/atoms/loader.vue";
import AcceptInvite from "./accept-invite.vue";
import Messages from "./messages.vue";

// States
const route = useRoute();
const pebbleStore = usePebbleStore();
const groupId = computed(() => (route.params.groupId as string) ?? (pebbleStore.groupSelected?.id) ?? null);
const showLoader = computed(() => !pebbleStore.groupSelected?.detailsFetchedForFirstTime);
const showAcceptInvite = computed(() => !pebbleStore.groupSelected?.allInvitesAccepted);

// Methods
watch(groupId, async (groupIdNew, groupIdOld) => {
    if (!!groupIdNew && groupIdNew !== groupIdOld) {
        // Fetch minimal group summary first if it does not exist
        if (!pebbleStore.groupSelected?.id) {
            pebbleStore.groupSelected = {
                id: groupIdNew,
                allInvitesAccepted: false,
                creator: "",
                messages: [],
                participants: [],
                detailsFetchedForFirstTime: false,
                didAcceptGroupInvite: false
            }
        }

        // Start syncing group details
        pebbleStore.startPoller();
    }
}, { immediate: true });
</script>

<template>
    <div class="group-chat">
        <!-- Loader -->
        <Loader v-if="showLoader" />

        <!-- Accept invite -->
        <AcceptInvite v-else-if="showAcceptInvite" />

        <!-- Messages -->
        <Messages v-else />
    </div>
</template>

<style lang="scss" scoped>
@use "@styles/_devices.scss";

.group-chat {
    width: 100%;
    position: relative;
    margin-top: 64px;
    height: calc(100vh - 64px - 1.5rem);

    @include devices.lg-tablet-and-desktop {
        height: 100%;
        margin-top: unset;
    }
}
</style>