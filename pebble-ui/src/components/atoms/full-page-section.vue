<script setup lang="ts">
</script>

<template>
    <v-container tag="section" class="full-page-section">
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

    @include devices.tablet-and-desktop {
        padding: 2rem;
    }
}
</style>
