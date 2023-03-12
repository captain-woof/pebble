import { Config } from "jest";

const config: Config = {
  moduleDirectories: ["node_modules"],
  moduleFileExtensions: ["js", "ts"],
  moduleNameMapper: {
    "@/(.+)": "<rootDir>/src/$1",
    "~/(.+)": "<rootDir>/$1",
    "types/(.+)": "<rootDir>/types/$1",
    "abi/(.+)": "<rootDir>/abi/$1"
  },
  transform: {
    "^.+\\.(js|ts)$": "ts-jest"
  },
  collectCoverage: true,
  collectCoverageFrom: [
    "src/**/index.{ts,js}",
    "!**/node_modules/**"
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    },
  },
}

export default config;