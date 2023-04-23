<script setup lang="ts">
import FullPageSection from "@components/atoms/full-page-section.vue";
import Contacts from "@components/molecules/contacts/index.vue";
import GroupChat from "@components/molecules/group-chat/index.vue";
</script>

<template>
    <FullPageSection class="full-page-section" spaceForNavbar>
        <div class="contacts-page">
            <!-- Contacts -->
            <div class="contacts-page__contacts-container">
                <Contacts />
            </div>

            <!-- Group chat -->
            <div class="contacts-page__group-chat-container">
                <GroupChat />
            </div>
        </div>
    </FullPageSection>
</template>

<style lang="scss" scoped>
@use "@styles/_devices.scss";

.full-page-section {
    display: flex;
}

.contacts-page {
    display: flex;
    align-items: center;
    width: 100%;

    .contacts-page__contacts-container {
        flex-grow: 1;
        height: 100%;

        @include devices.lg-tablet-and-desktop {
            flex-grow: unset;
            width: 256px;
        }
    }

    .contacts-page__group-chat-container {
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