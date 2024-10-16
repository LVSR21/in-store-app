module.exports = {
    transform: {
      "^.+\\.jsx?$": "babel-jest", // Use babel-jest for .js and .jsx files
    },
    transformIgnorePatterns: [
      "/node_modules/(?!(axios)/)", // Transpile axios and any other module using ES module syntax
    ],
    testEnvironment: "jsdom", // Make sure you're using the correct environment for React testing
  };
