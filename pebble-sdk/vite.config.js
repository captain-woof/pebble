import { defineConfig } from "vite";
import dts from "vite-plugin-dts";

export default defineConfig(({ mode }) => {
    return {
        build: {
            lib: {
                entry: "src/index.ts",
                name: "PebbleSDK",
                fileName: "pebble-sdk"
            },
            emptyOutDir: true,
            minify: true
        },
        clearScreen: true,
        resolve: {
            alias: {
                "@/": "src/"
            }
        },
        plugins: [
            dts()
        ]
    }
});