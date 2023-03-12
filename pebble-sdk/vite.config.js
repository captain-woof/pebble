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
            minify: "terser",
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
        plugins: [
            dts({
                tsConfigFilePath: "tsconfig.build.json",
                entryRoot: "src",
                outputDir: "dist/types"
            })
        ]
    }
});