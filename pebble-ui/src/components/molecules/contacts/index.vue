<script setup lang="ts">
import { defineProps } from 'vue';
import CreateNewGroup from "./create-new-group.vue";

// Props
const props = defineProps({
    tag: {
        default: "div",
        required: false,
        type: String
    }
});

// States

</script>

<template>
    <component :is="props.tag" class="contacts">
        <!-- Heading -->
        <h1 class="text-h5">
            Contacts
        </h1>

        <!-- List of contacts -->

        <!-- Create new group -->
        <CreateNewGroup />
    </component>
</template>

<style lang="scss" scoped>
.contacts {
    height: 100%;
    position: relative;

    
}
</style>