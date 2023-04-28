<script setup lang="ts">
import Loader from '@components/atoms/loader.vue';
import usePebbleStore, { IPebbleStoreState } from '@store/pebble';
import { defineProps, computed } from 'vue';
import CreateNewGroup from "./create-new-group.vue";
import GroupsList from './groups-list.vue';

// Props
const props = defineProps({
    tag: {
        default: "div",
        required: false,
        type: String
    }
});

// States
const pebbleStore = usePebbleStore();
const showGroupsList = computed(() => pebbleStore.groupsSummary.length !== 0);

// Emits
const emit = defineEmits<{
    (e: "groupClick", group: IPebbleStoreState["groupsSummary"][0]): void
}>();

</script>

<template>
    <component :is="props.tag" class="groups">
        <!-- Heading -->
        <h1 class="text-h5">
            Groups
        </h1>

        <!-- List of groups -->
        <GroupsList v-if="showGroupsList" @groupClick="(group: any) => emit('groupClick', group)" />
        <Loader v-else />

        <!-- Create new group -->
        <CreateNewGroup />
    </component>
</template>

<style lang="scss" scoped>
.groups {
    height: 100%;
    position: relative;
}
</style>