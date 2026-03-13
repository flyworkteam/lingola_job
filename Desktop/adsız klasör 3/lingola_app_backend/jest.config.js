/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: "node",
  testMatch: ["**/__tests__/**/*.test.js"],
  collectCoverageFrom: ["src/**/*.js", "!src/config/**", "!src/__tests__/**"],
  coverageDirectory: "coverage",
  verbose: true,
  watchman: false,
  // Proje içindeki kopya Desktop/... klasörünü görmezden gel (haste naming collision önlenir)
  modulePathIgnorePatterns: ["<rootDir>/Desktop"],
  testPathIgnorePatterns: ["/node_modules/", "<rootDir>/Desktop"],
};
