<script setup lang="ts">
import { defineProps } from 'vue';

// Props
const props = defineProps({
    tag: {
        default: "div",
        required: false,
        type: String
    },
    groupId: {
        default: null,
        required: false,
        type: Number
    }
});

// States


</script>

<template>
    <component :is="props.tag" class="group-chat">
        GROUP-CHAT
    </component>
</template>

<style lang="scss" scoped>
.group-chat {
    height: 100%;
}
</style>