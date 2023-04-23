<script setup lang="ts">
import { defineProps } from 'vue';

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
        CONTACTS
    </component>
</template>

<style lang="scss" scoped>
.contacts {
    height: 100%;
}
</style>