const fs = require('fs');
const path = require('path');

describe('Firestore Security Rules Validation', () => {
  let rulesContent;

  beforeAll(() => {
    rulesContent = fs.readFileSync('firestore.rules', 'utf8');
  });

  test('Rules file exists and is readable', () => {
    expect(rulesContent).toBeDefined();
    expect(rulesContent.length).toBeGreaterThan(0);
  });

  test('Rules version is specified', () => {
    expect(rulesContent).toMatch(/rules_version\s*=\s*['"]2['"];/);
  });

  test('Service cloud.firestore is defined', () => {
    expect(rulesContent).toMatch(/service\s+cloud\.firestore/);
  });

  test('User data isolation rules are present', () => {
    expect(rulesContent).toMatch(/match\s+\/users\/\{userId\}/);
    expect(rulesContent).toMatch(/request\.auth\.uid\s*==\s*userId/);
  });

  test('Asset validation function exists', () => {
    expect(rulesContent).toMatch(/function\s+validateAssetData\s*\(/);
    expect(rulesContent).toMatch(/data\.keys\(\)\.hasAll\(\['name',\s*'type',\s*'balance',\s*'createdAt',\s*'updatedAt'\]\)/);
  });

  test('Category validation function exists', () => {
    expect(rulesContent).toMatch(/function\s+validateCategoryData\s*\(/);
    expect(rulesContent).toMatch(/data\.keys\(\)\.hasAll\(\['name',\s*'description',\s*'icon'\]\)/);
  });

  test('Transaction validation function exists', () => {
    expect(rulesContent).toMatch(/function\s+validateTransactionData\s*\(/);
    expect(rulesContent).toMatch(/data\.keys\(\)\.hasAll\(\['assetId',\s*'categoryId',\s*'amount',\s*'description',\s*'date',\s*'createdAt'\]\)/);
  });

  test('Asset type validation includes all required types', () => {
    const assetTypes = ['paymentAccount', 'savingsAccount', 'gold', 'loan', 'realEstate', 'other'];
    assetTypes.forEach(type => {
      expect(rulesContent).toMatch(new RegExp(`'${type}'`));
    });
  });

  test('Authentication is required for all operations', () => {
    const authChecks = rulesContent.match(/request\.auth\s*!=\s*null/g);
    expect(authChecks).toBeDefined();
    expect(authChecks.length).toBeGreaterThan(5); // Should have multiple auth checks
  });

  test('Balance validation prevents negative values', () => {
    expect(rulesContent).toMatch(/data\.balance\s*>=\s*0/);
  });

  test('Amount validation prevents zero and negative values', () => {
    expect(rulesContent).toMatch(/data\.amount\s*>\s*0/);
  });

  test('String validation prevents empty names', () => {
    expect(rulesContent).toMatch(/data\.name\.size\(\)\s*>\s*0/);
  });

  test('Timestamp validation is present', () => {
    expect(rulesContent).toMatch(/is\s+timestamp/);
  });
});

describe('Firebase Configuration Validation', () => {
  test('firebase.json exists and is valid', () => {
    const firebaseConfig = JSON.parse(fs.readFileSync('firebase.json', 'utf8'));
    
    expect(firebaseConfig.firestore).toBeDefined();
    expect(firebaseConfig.firestore.rules).toBe('firestore.rules');
    expect(firebaseConfig.firestore.indexes).toBe('firestore.indexes.json');
    
    expect(firebaseConfig.emulators).toBeDefined();
    expect(firebaseConfig.emulators.firestore).toBeDefined();
    expect(firebaseConfig.emulators.auth).toBeDefined();
  });

  test('firestore.indexes.json exists and is valid', () => {
    const indexesConfig = JSON.parse(fs.readFileSync('firestore.indexes.json', 'utf8'));
    
    expect(indexesConfig.indexes).toBeDefined();
    expect(Array.isArray(indexesConfig.indexes)).toBe(true);
    
    // Check for transaction date index
    const transactionDateIndex = indexesConfig.indexes.find(
      index => index.collectionGroup === 'transactions' && 
      index.fields.some(field => field.fieldPath === 'date')
    );
    expect(transactionDateIndex).toBeDefined();
  });
});