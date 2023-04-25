<script setup lang="ts">
</script>

<template>
    <div class="loader pa-2 pa-sm-4 d-flex flex-column justify-center align-center h-100 w-100 progress">
        <div class="progress__container">
            <v-progress-linear indeterminate rounded-bar rounded height="4" width="10"></v-progress-linear>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.progress {
    .progress__container {
        width: 100px;
    }
}
</style>