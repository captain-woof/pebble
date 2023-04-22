import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import vuetify, { transformAssetUrls } from "vite-plugin-vuetify";
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  resolve: {
    alias: {
      "@components": path.resolve(__dirname, "src", "components"),
      "@styles": path.resolve(__dirname, "src", "styles")
    }
  },
  plugins: [
    vue({
      template: { transformAssetUrls }
    }),
    vuetify({
      styles: {
        configFile: "src/styles/vuetify/_settings.scss"
      }
    }),
  ],
})
