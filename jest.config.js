module.exports = {
    globalSetup: "<rootDir>/tests-setup.js",
    globalTeardown: "<rootDir>/tests-teardown.js",
    modulePathIgnorePatterns: ["./test/fixtures", "./test/helpers"],
    collectCoverage: true
  };