<script setup lang="ts">
import FullPageSection from "@components/atoms/full-page-section.vue";
import { useRoute } from "vue-router";
import { computed } from "vue";

// States
const route = useRoute();
const groupId = computed(() => route.params.groupId ? parseInt(route.params.groupId as string) : null);

</script>

<template>
    <FullPageSection>
        
    </FullPageSection>
</template>

<style lang="scss" scoped></style>