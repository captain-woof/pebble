<script setup lang="ts">
</script>

<template>
    <section class="full-page-section">
        <slot>
        </slot>
    </section>
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
