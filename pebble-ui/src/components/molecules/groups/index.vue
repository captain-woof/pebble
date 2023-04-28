<script setup lang="ts">
import { IPebbleStoreState } from '@store/pebble';
import { defineProps } from 'vue';
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
        <GroupsList @groupClick="(group: any) => emit('groupClick', group)" />

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