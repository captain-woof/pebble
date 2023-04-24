<script setup lang="ts">
import usePebbleStore from '@store/pebble';
import { computed, defineEmits } from 'vue';
import { shortenAddress } from "@utils/string";

// States
const pebbleStore = usePebbleStore();
const groupsSummaryForList = computed(() => pebbleStore.groupsSummary.map(({ participants, messages, id, creator, allInvitesAccepted }) => ({
    id,
    title: participants.reduce((titlePartial, { invitee }, i) => (`${titlePartial}, ${shortenAddress(invitee)}`), "You"),
    subtitle: !allInvitesAccepted
        ? "Awaiting participants to accept invites"
        : (
            messages[0]?.timestamp ? `${new Date(messages[0].timestamp as string).toLocaleTimeString()} • ${shortenAddress(messages[0].sender)}` : "No messages yet"
        ),
    allInvitesAccepted
})));

// Emits
const emit = defineEmits<{
    (e: "groupClick", group: typeof groupsSummaryForList.value[0]): void
}>();

// Methods
async function handleGroupClick(group: typeof groupsSummaryForList.value[0]) {
    emit("groupClick", group);
}
</script>

<template>
    <v-list tag="ul" class="groups-list my-2">
        <v-list-item v-for="(group, i) in groupsSummaryForList" lines="three" tag="li" :key="group.id"
            @click="handleGroupClick(group)">
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

            <!-- Divider, if needed -->
            <v-divider v-if="i !== groupsSummaryForList.length - 1"></v-divider>
        </v-list-item>
    </v-list>
</template>

<style scoped lang="scss">
.groups-list {
    overflow-y: auto;
    height: calc(100% - 32px);
}
</style>