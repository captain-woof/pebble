<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from "vue-router";
import ConnectBtn from '@components/atoms/connect-btn.vue';

// States
const route = useRoute();
const showAppBar = computed(() => route.name !== "home");
</script>

<template>
    <v-app-bar v-if="showAppBar" :elevation="2" class="app-bar">
        <!-- App name -->
        <v-app-bar-title>
            Pebble
        </v-app-bar-title>

        <!-- Actions -->
        <template v-slot:append>
            <!-- Connect button -->
            <ConnectBtn />
        </template>
    </v-app-bar>
</template>

<style lang="scss" scoped>
.app-bar {
    z-index: calc(var(--w3m-z-index) - 1) !important;
}
</style>