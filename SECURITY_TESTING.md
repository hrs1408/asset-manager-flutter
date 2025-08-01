# Firebase Security Rules Testing

This document explains how to test the Firestore security rules for the Quan Ly Tai San application.

## Prerequisites

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Install test dependencies:
   ```bash
   npm install
   ```

## Security Rules Overview

The security rules ensure:
- **User Data Isolation**: Each user can only access their own data
- **Authentication Required**: All operations require authentication
- **Data Validation**: Strict validation for asset, category, and transaction data
- **Type Safety**: Ensures correct data types and valid enum values

## Testing the Security Rules

### 1. Start Firebase Emulator

```bash
firebase emulators:start --only firestore,auth
```

The emulator will start on:
- Firestore: http://localhost:8080
- Auth: http://localhost:9099
- UI: http://localhost:4000

### 2. Run Security Tests

```bash
npm run test:security
```

Or run with emulator auto-start:
```bash
npm run emulator:test
```

## Test Coverage

The security tests cover:

### User Data Isolation
- ✅ Users can read their own data
- ✅ Users cannot read other users' data
- ✅ Unauthenticated users cannot access any data

### Asset Security
- ✅ Valid asset creation with proper fields
- ✅ Rejection of invalid asset types
- ✅ Rejection of negative balances
- ✅ Cross-user access prevention

### Category Security
- ✅ Valid category creation
- ✅ Rejection of empty category names
- ✅ Cross-user access prevention

### Transaction Security
- ✅ Valid transaction creation
- ✅ Rejection of zero/negative amounts
- ✅ Cross-user access prevention

## Security Rule Validation Functions

### validateAssetData(data)
Validates:
- Required fields: name, type, balance, createdAt, updatedAt
- name: non-empty string
- type: valid enum value
- balance: non-negative number
- timestamps: proper timestamp format

### validateCategoryData(data)
Validates:
- Required fields: name, description, icon
- name: non-empty string
- description: string
- icon: string
- isDefault: boolean (optional)

### validateTransactionData(data)
Validates:
- Required fields: assetId, categoryId, amount, description, date, createdAt
- assetId/categoryId: non-empty strings
- amount: positive number
- description: string
- timestamps: proper timestamp format

## Manual Testing

You can also manually test the rules using the Firebase Emulator UI:

1. Open http://localhost:4000
2. Go to Firestore tab
3. Try creating documents with different user contexts
4. Verify that cross-user access is blocked

## Production Deployment

After testing, deploy the rules to production:

```bash
firebase deploy --only firestore:rules
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Change ports in firebase.json if needed
2. **Permission denied**: Ensure you're authenticated with Firebase CLI
3. **Test failures**: Check that emulator is running before tests

### Debug Mode

Enable debug logging in tests:
```javascript
setLogLevel('debug');
```

## Security Best Practices

1. **Principle of Least Privilege**: Users can only access their own data
2. **Input Validation**: All data is validated before storage
3. **Type Safety**: Strict type checking prevents data corruption
4. **Authentication Required**: No anonymous access allowed
5. **Audit Trail**: All operations are logged with timestamps