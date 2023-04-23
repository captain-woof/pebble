<script setup lang="ts">
import AppBar from "@components/molecules/app-bar/index.vue";
import MainContainer from '@components/atoms/main-container.vue';
import Toast from "@components/molecules/toast/index.vue";
</script>

<template>
  <v-layout>
    <!-- AppBar -->
    <AppBar />

    <!-- Vue route component -->
    <MainContainer>
      <router-view>
      </router-view>
    </MainContainer>

    <!-- Toast -->
    <Toast />
  </v-layout>
</template>

<style scoped></style>
