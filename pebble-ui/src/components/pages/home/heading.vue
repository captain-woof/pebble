<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useDisplay } from "vuetify";

// Constants

// Features to show-case
const featuresMobile = [
    "e2e encrypted",
    "open-sourced",
    "group chat",
]

const features = [
    "e2e encrypted",
    "group",
    "open-sourced"
]

// States
const featureToShowIndex = ref(0);
const intervalId = ref<NodeJS.Timer | null>(null);
const { smAndUp } = useDisplay();
const featuresToShow = computed(() => (smAndUp.value ? features : featuresMobile).filter((_, i) => i === featureToShowIndex.value));

// Methods
onMounted(() => {
    // Set feature transition timer
    intervalId.value = setInterval(() => {
        featureToShowIndex.value = (featureToShowIndex.value + 1) % features.length;
    }, 3000)
});

onUnmounted(() => {
    // Clear feature transition timer
    if (intervalId.value)
        clearInterval(intervalId.value);
});
</script>

<template>
    <h1 class="text-h2 text-sm-h1 heading">
        <!-- Logo -->
        <img src="/logos/pebble-rounded-rectangle.png" alt="pebble logo" class="heading__logo" />

        <!-- App name -->
        <span class="ml-2">Pebble</span>
    </h1>

    <h1 class="text-h4 text-sm-h2 sub-heading">
        <!-- Features -->
        <TransitionGroup name="feature" tag="div" class="sub-heading__features mt-4">
            <span v-for="feature in featuresToShow" :key="feature" class="sub-heading__features__feature">
                {{ feature }}
            </span>
        </TransitionGroup>

        <!-- Chat -->
        <span v-if="smAndUp" class="text-center">
            chat
        </span>
    </h1>
</template>

<style lang="scss" scoped>
@use "@styles/_devices";

.heading {
    text-align: center;
    display: flex;
    align-items: center;
    width: 100%;
    justify-content: center;

    .heading__logo {
        $dimension: 72px;
        display: block;
        max-width: 100%;
        animation: rotate-into-place 1.5s ease-out;
        width: $dimension;

        @include devices.tablet-and-desktop {
            $dimension: 120px;
            width: $dimension;
        }

        @keyframes rotate-into-place {
            0% {
                transform: rotate(-24deg);
            }

            100% {
                transform: rotate(0deg);
            }
        }
    }
}

.sub-heading {
    display: flex;
    flex-direction: column;
    align-items: center;
    font-weight: bold;
    width: 100%;

    &>* {
        display: block;
        width: 100%;
    }

    .sub-heading__features {
        position: relative;
        width: 80vw;
        height: 60px;

        .sub-heading__features__feature {
            position: absolute;
            text-align: center;
            width: 100%;
            left: 0;
            top: 0;
            transition: all 0.75s ease-in-out;

            &.feature-enter-from {
                transform: translateY(25%);
                opacity: 0;
            }

            &.feature-enter-to,
            &.feature-leave-from {
                transform: translateY(0%);
                opacity: 1;
            }

            &.feature-leave-to {
                transform: translateY(-25%);
                opacity: 0;
            }
        }
    }
}
</style>