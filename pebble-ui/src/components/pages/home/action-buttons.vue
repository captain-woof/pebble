<script setup lang="ts">
// Methods
function handleGetStarted() {

}
</script>

<template>
    <div class="action-btns mt-6">
        <!-- Learn more -->
        <a href="https://captain-woof.gitbook.io/pebble-protocol/" target="_blank">
            <v-btn prepend-icon="mdi-book-open">
                Learn more
            </v-btn>
        </a>

        <!-- Get started -->
        <v-btn class="ml-sm-2" append-icon="mdi-send-variant" @click="handleGetStarted">
            Get started
        </v-btn>
    </div>
</template>

<style lang="scss" scoped>
.action-btns {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;

    &>* {
        min-width: 160px;
    }
}

a {
    text-decoration: none;
    color: unset;
}
</style>