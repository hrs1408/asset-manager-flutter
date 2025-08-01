// Jest setup file for Firebase Rules Unit Testing
const { setLogLevel } = require('firebase/firestore');

// Reduce Firebase logging during tests
setLogLevel('error');

// Set test timeout
jest.setTimeout(30000);