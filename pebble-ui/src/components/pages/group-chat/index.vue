<script setup lang="ts">
import { onUnmounted } from "vue";
import FullPageSection from "@components/atoms/full-page-section.vue";
import GroupChat from "@components/molecules/group-chat/index.vue";
import usePebbleStore from "@store/pebble";

// States
const pebbleStore = usePebbleStore();

// Methods
onUnmounted(() => {
    pebbleStore.deselectGroupSelected();
})
</script>

<template>
    <FullPageSection class="group-chat-page">
        <GroupChat />
    </FullPageSection>
</template>

<style lang="scss" scoped>
.group-chat-page {
    height: 100%;
}
</style>