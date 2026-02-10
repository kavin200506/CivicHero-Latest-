#!/usr/bin/env node

/**
 * ⚠️ WARNING: This script will DELETE ALL DATA from Firebase!
 * - All Firestore collections and documents
 * - All Authentication users
 * 
 * Use with extreme caution!
 */

const admin = require('firebase-admin');
const readline = require('readline');

// Firebase configuration
const firebaseConfig = {
  projectId: 'civicissue-aae6d',
  // Note: For Admin SDK, we need service account key
  // OR we can use Application Default Credentials
};

// Initialize Firebase Admin SDK
let initialized = false;

// Option 1: Try using service account key file (if exists)
try {
  const serviceAccount = require('./service-account-key.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'civicissue-aae6d'
  });
  console.log('✅ Firebase Admin SDK initialized (using service account key)');
  initialized = true;
} catch (error) {
  // Service account key not found, try other methods
}

// Option 2: Try Application Default Credentials (if gcloud is set up)
if (!initialized) {
  try {
    admin.initializeApp({
      projectId: 'civicissue-aae6d'
    });
    console.log('✅ Firebase Admin SDK initialized (using Application Default Credentials)');
    initialized = true;
  } catch (error) {
    // Application Default Credentials not available
  }
}

// If still not initialized, show error
if (!initialized) {
  console.error('❌ Error: Could not initialize Firebase Admin SDK');
  console.log('\n💡 You need to provide authentication. Choose one:');
  console.log('\n   Option 1: Get Service Account Key (Recommended)');
  console.log('   1. Go to Firebase Console > Project Settings > Service accounts');
  console.log('   2. Click "Generate new private key"');
  console.log('   3. Save as "service-account-key.json" in this directory');
  console.log('\n   Option 2: Use Application Default Credentials');
  console.log('   Run: gcloud auth application-default login');
  console.log('\n   Option 3: Use Firebase Console (Easiest)');
  console.log('   Manually delete data from Firebase Console');
  process.exit(1);
}

const db = admin.firestore();
const auth = admin.auth();

// Helper function to delete a collection
async function deleteCollection(collectionPath) {
  const collectionRef = db.collection(collectionPath);
  const snapshot = await collectionRef.get();
  
  if (snapshot.empty) {
    console.log(`   ✓ Collection "${collectionPath}" is already empty`);
    return 0;
  }

  const batchSize = 500;
  let deletedCount = 0;
  
  // Delete in batches
  let batch = db.batch();
  let count = 0;
  
  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    count++;
    deletedCount++;
    
    if (count >= batchSize) {
      await batch.commit();
      batch = db.batch();
      count = 0;
      console.log(`   📝 Deleted ${deletedCount} documents from "${collectionPath}"...`);
    }
  }
  
  if (count > 0) {
    await batch.commit();
  }
  
  return deletedCount;
}

// Delete all Firestore collections
async function clearFirestore() {
  console.log('\n🗑️  Clearing Firestore Database...');
  console.log('=' .repeat(60));
  
  try {
    // Get all collections
    const collections = await db.listCollections();
    
    if (collections.length === 0) {
      console.log('✅ Firestore is already empty!');
      return;
    }
    
    console.log(`📋 Found ${collections.length} collection(s):`);
    collections.forEach(col => console.log(`   - ${col.id}`));
    
    let totalDeleted = 0;
    
    for (const collection of collections) {
      const deleted = await deleteCollection(collection.id);
      totalDeleted += deleted;
    }
    
    console.log('\n✅ Firestore cleared successfully!');
    console.log(`   Total documents deleted: ${totalDeleted}`);
  } catch (error) {
    console.error('❌ Error clearing Firestore:', error);
    throw error;
  }
}

// Delete all authentication users
async function clearAuthentication() {
  console.log('\n🗑️  Clearing Authentication Users...');
  console.log('=' .repeat(60));
  
  try {
    let deletedCount = 0;
    let nextPageToken;
    
    do {
      const listUsersResult = await auth.listUsers(1000, nextPageToken);
      
      if (listUsersResult.users.length === 0) {
        console.log('✅ No users to delete');
        break;
      }
      
      console.log(`📋 Found ${listUsersResult.users.length} user(s) to delete...`);
      
      // Delete users in batch
      const deletePromises = listUsersResult.users.map(user => {
        console.log(`   🗑️  Deleting user: ${user.email || user.uid}`);
        return auth.deleteUser(user.uid);
      });
      
      await Promise.all(deletePromises);
      deletedCount += listUsersResult.users.length;
      
      nextPageToken = listUsersResult.pageToken;
    } while (nextPageToken);
    
    console.log(`\n✅ Authentication cleared successfully!`);
    console.log(`   Total users deleted: ${deletedCount}`);
  } catch (error) {
    console.error('❌ Error clearing Authentication:', error);
    throw error;
  }
}

// Main function
async function main() {
  console.log('\n' + '='.repeat(60));
  console.log('⚠️  FIREBASE DATA CLEARING SCRIPT');
  console.log('='.repeat(60));
  console.log('⚠️  WARNING: This will DELETE ALL DATA!');
  console.log('   - All Firestore collections and documents');
  console.log('   - All Authentication users');
  console.log('='.repeat(60));
  
  // Ask for confirmation
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  
  const answer = await new Promise(resolve => {
    rl.question('\n❓ Are you sure you want to delete ALL data? (type "DELETE ALL" to confirm): ', resolve);
  });
  
  rl.close();
  
  if (answer !== 'DELETE ALL') {
    console.log('\n❌ Operation cancelled. Data was not deleted.');
    process.exit(0);
  }
  
  try {
    // Clear Firestore
    await clearFirestore();
    
    // Clear Authentication
    await clearAuthentication();
    
    console.log('\n' + '='.repeat(60));
    console.log('✅ ALL DATA CLEARED SUCCESSFULLY!');
    console.log('='.repeat(60));
    console.log('\n📝 Next steps:');
    console.log('   - Users will need to register again');
    console.log('   - All complaints/issues have been deleted');
    console.log('   - Admin accounts need to be recreated');
    
  } catch (error) {
    console.error('\n❌ Error during data clearing:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

// Run the script
main();

