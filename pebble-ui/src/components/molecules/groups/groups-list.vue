<script setup lang="ts">
import usePebbleStore from '@store/pebble';
import { utils } from 'ethers';
import { computed, defineEmits } from 'vue';
import { shortenAddress, convertUnixSecsToHumanFormatDateTime, convertUnixSecsToTimeFromNow } from "@utils/string";
import useWalletStore from '@store/wallet';

// States
const walletStore = useWalletStore();
const pebbleStore = usePebbleStore();
const groupsSummaryForList = computed(() => pebbleStore.groupsSummary.map(({ participants, messages, id, creator, allInvitesAccepted }) => ({
    id,
    title: [
        creator,
        ...participants.map(({ invitee }) => invitee)
    ]
        .filter((address) => utils.getAddress(address) !== walletStore.account?.address)
        .map(shortenAddress)
        .join(", "),
    subtitle: !allInvitesAccepted
        ? "Awaiting participants to accept invites"
        : (
            messages[0]?.timestamp ? `${convertUnixSecsToTimeFromNow(messages[0]?.timestamp)} • ${shortenAddress(messages[0].sender)}` : "No messages yet"
        ),
    allInvitesAccepted
})));

// Emits
const emit = defineEmits<{
    (e: "groupClick", group: typeof pebbleStore.groupsSummary[0]): void
}>();

// Methods
async function handleGroupClick(groupIndex: number) {
    emit("groupClick", pebbleStore.groupsSummary[groupIndex]);
}
</script>

<template>
    <v-list tag="ul" class="groups-list my-2">
        <div v-for="(group, i) in groupsSummaryForList">
            <!-- Group details -->
            <v-list-item lines="three" tag="li" :key="group.id" @click="handleGroupClick(i)">
                <!-- Title -->
                <v-list-item-title>
                    {{ group.title }}
                </v-list-item-title>

                <!-- Subtitle -->
                <v-list-item-subtitle>
                    <span>
                        {{ group.subtitle }}
                    </span>

                    <!-- Loader, if needed -->
                    <v-progress-circular v-if="!group.allInvitesAccepted" indeterminate size="12" width="1"
                        class="ml-1"></v-progress-circular>
                </v-list-item-subtitle>
            </v-list-item>

            <!-- Divider, if needed -->
            <v-divider v-if="i !== groupsSummaryForList.length - 1"></v-divider>
        </div>
    </v-list>
</template>

<style scoped lang="scss">
.groups-list {
    overflow-y: auto;
    height: calc(100% - 32px);
}
</style>