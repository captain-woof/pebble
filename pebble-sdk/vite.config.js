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
            minify: true,
            rollupOptions: {
                external: [
                    "ethers",
                    "@noble/secp256k1"
                ]
            }
        },
        resolve: {
            alias: {
                "@/": "src/",
                "~/": "./",
                "types/": "types/",
                "abi/": "abi/"
            }
        },
        plugins: []
    }
});