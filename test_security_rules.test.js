const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, collection, addDoc, query, where, getDocs } = require('firebase/firestore');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'quan-ly-tai-san-test',
    firestore: {
      rules: require('fs').readFileSync('firestore.rules', 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

afterAll(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe('Firestore Security Rules', () => {
  const userId1 = 'user1';
  const userId2 = 'user2';

  describe('User Data Isolation', () => {
    test('User can read their own data', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const userDoc = doc(db, `users/${userId1}`);
      
      await assertSucceeds(getDoc(userDoc));
    });

    test('User cannot read other user data', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const otherUserDoc = doc(db, `users/${userId2}`);
      
      await assertFails(getDoc(otherUserDoc));
    });

    test('Unauthenticated user cannot read any data', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      const userDoc = doc(db, `users/${userId1}`);
      
      await assertFails(getDoc(userDoc));
    });
  });

  describe('Asset Security Rules', () => {
    test('User can create valid asset', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const assetRef = doc(db, `users/${userId1}/assets/asset1`);
      
      const validAsset = {
        name: 'Test Asset',
        type: 'paymentAccount',
        balance: 1000,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      await assertSucceeds(setDoc(assetRef, validAsset));
    });

    test('User cannot create asset with invalid type', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const assetRef = doc(db, `users/${userId1}/assets/asset1`);
      
      const invalidAsset = {
        name: 'Test Asset',
        type: 'invalidType',
        balance: 1000,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      await assertFails(setDoc(assetRef, invalidAsset));
    });

    test('User cannot create asset with negative balance', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const assetRef = doc(db, `users/${userId1}/assets/asset1`);
      
      const invalidAsset = {
        name: 'Test Asset',
        type: 'paymentAccount',
        balance: -100,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      await assertFails(setDoc(assetRef, invalidAsset));
    });

    test('User cannot access other user assets', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const otherUserAssetRef = doc(db, `users/${userId2}/assets/asset1`);
      
      await assertFails(getDoc(otherUserAssetRef));
    });
  });

  describe('Category Security Rules', () => {
    test('User can create valid category', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const categoryRef = doc(db, `users/${userId1}/categories/category1`);
      
      const validCategory = {
        name: 'Test Category',
        description: 'Test Description',
        icon: 'test_icon',
        isDefault: false
      };

      await assertSucceeds(setDoc(categoryRef, validCategory));
    });

    test('User cannot create category with empty name', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const categoryRef = doc(db, `users/${userId1}/categories/category1`);
      
      const invalidCategory = {
        name: '',
        description: 'Test Description',
        icon: 'test_icon'
      };

      await assertFails(setDoc(categoryRef, invalidCategory));
    });

    test('User cannot access other user categories', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const otherUserCategoryRef = doc(db, `users/${userId2}/categories/category1`);
      
      await assertFails(getDoc(otherUserCategoryRef));
    });
  });

  describe('Transaction Security Rules', () => {
    test('User can create valid transaction', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const transactionRef = doc(db, `users/${userId1}/transactions/transaction1`);
      
      const validTransaction = {
        assetId: 'asset1',
        categoryId: 'category1',
        amount: 100,
        description: 'Test transaction',
        date: new Date(),
        createdAt: new Date()
      };

      await assertSucceeds(setDoc(transactionRef, validTransaction));
    });

    test('User cannot create transaction with zero amount', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const transactionRef = doc(db, `users/${userId1}/transactions/transaction1`);
      
      const invalidTransaction = {
        assetId: 'asset1',
        categoryId: 'category1',
        amount: 0,
        description: 'Test transaction',
        date: new Date(),
        createdAt: new Date()
      };

      await assertFails(setDoc(transactionRef, invalidTransaction));
    });

    test('User cannot create transaction with negative amount', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const transactionRef = doc(db, `users/${userId1}/transactions/transaction1`);
      
      const invalidTransaction = {
        assetId: 'asset1',
        categoryId: 'category1',
        amount: -50,
        description: 'Test transaction',
        date: new Date(),
        createdAt: new Date()
      };

      await assertFails(setDoc(transactionRef, invalidTransaction));
    });

    test('User cannot access other user transactions', async () => {
      const db = testEnv.authenticatedContext(userId1).firestore();
      const otherUserTransactionRef = doc(db, `users/${userId2}/transactions/transaction1`);
      
      await assertFails(getDoc(otherUserTransactionRef));
    });
  });
});