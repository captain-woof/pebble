<script setup lang="ts">
import { computed } from "vue";
import useToastStore from '@store/toast';

// States
const toastState = useToastStore();
const showToast = computed(() => !!toastState.toastMessage);
</script>

<template>
    <v-snackbar v-model="showToast">
        {{ toastState.toastMessage }}
    </v-snackbar>
</template>

<style lang="scss" scoped></style>