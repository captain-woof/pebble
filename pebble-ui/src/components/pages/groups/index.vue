<script setup lang="ts">
import FullPageSection from "@components/atoms/full-page-section.vue";
import Groups from "@components/molecules/groups/index.vue";
import GroupChat from "@components/molecules/group-chat/index.vue";
</script>

<template>
    <FullPageSection class="full-page-section" spaceForNavbar>
        <div class="groups-page">
            <!-- Groups -->
            <div class="groups-page__groups-container">
                <Groups />
            </div>

            <!-- Group chat -->
            <div class="groups-page__group-chat-container">
                <GroupChat />
            </div>
        </div>
    </FullPageSection>
</template>

<style lang="scss" scoped>
@use "@styles/_devices.scss";

.full-page-section {
    display: flex;
    height: calc(100vh - 64px) !important;
}

.groups-page {
    display: flex;
    align-items: center;
    width: 100%;

    .groups-page__groups-container {
        flex-grow: 1;
        height: 100%;

        @include devices.lg-tablet-and-desktop {
            flex-grow: unset;
            width: 256px;
        }
    }

    .groups-page__group-chat-container {
        flex-grow: 0;
        display: none;
        height: 100%;

        @include devices.lg-tablet-and-desktop {
            flex-grow: 1;
            display: unset;
        }
    }
}
</style>