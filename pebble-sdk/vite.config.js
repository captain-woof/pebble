import { defineConfig } from "vite";

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
        resolve: {
            alias: {
                "@/": "src/"
            }
        },
        plugins: []
    }
});