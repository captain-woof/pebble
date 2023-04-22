<script setup lang="ts">
import FullPageSection from "@components/atoms/full-page-section.vue";
import Heading from "./heading.vue";
import ActionButtons from "./action-buttons.vue";
</script>

<template>
    <FullPageSection class="home-page">
        <!-- Heading -->
        <Heading />

        <!-- Action buttons -->
        <ActionButtons />
    </FullPageSection>
</template>

<style lang="scss" scoped>
.home-page {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}
</style>