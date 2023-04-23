<script setup lang="ts">
import { defineProps } from 'vue';

// Props
const props = defineProps({
    spaceForNavbar: {
        type: Boolean,
        default: false
    }
});
</script>

<template>
    <v-container tag="section" class="full-page-section"
        :class="{ 'full-page-section--space-for-navbar': props.spaceForNavbar }">
        <slot>
        </slot>
    </v-container>
</template>

<style scoped lang="scss">
@use "@styles/_devices.scss";

.full-page-section {
    min-height: 100vh;
    width: 100%;
    max-width: 900px;
    padding: 0.5rem;
    margin: 0 auto;
    display: block;

    &--space-for-navbar {
        min-height: calc(100vh - 64px);
        margin: 64px auto 0 auto;
    }

    @include devices.tablet-and-desktop {
        padding: 2rem;
    }
}
</style>
