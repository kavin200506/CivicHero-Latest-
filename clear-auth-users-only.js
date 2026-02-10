#!/usr/bin/env node

/**
 * Script to delete ALL Authentication users only
 * (Firestore is already cleared)
 */

const admin = require('firebase-admin');
const readline = require('readline');

// Initialize Firebase Admin SDK
let initialized = false;

// Try using service account key file
try {
  const serviceAccount = require('./service-account-key.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'civicissue-aae6d'
  });
  console.log('✅ Firebase Admin SDK initialized');
  initialized = true;
} catch (error) {
  // Service account key not found
}

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

if (!initialized) {
  console.error('❌ Could not initialize Firebase Admin SDK');
  console.log('💡 Make sure service-account-key.json exists in this directory');
  process.exit(1);
}

const auth = admin.auth();

// Delete all authentication users
async function clearAuthentication() {
  console.log('\n🗑️  Clearing Authentication Users...');
  console.log('='.repeat(60));
  
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
      console.log(`   ✅ Deleted ${listUsersResult.users.length} users in this batch`);
      
      nextPageToken = listUsersResult.pageToken;
    } while (nextPageToken);
    
    console.log(`\n✅ Authentication cleared successfully!`);
    console.log(`   Total users deleted: ${deletedCount}`);
  } catch (error) {
    console.error('\n❌ Error clearing Authentication:', error.message);
    
    if (error.message.includes('PERMISSION_DENIED') || error.message.includes('403')) {
      console.log('\n💡 Solution: Enable Identity Toolkit API');
      console.log('   1. Go to: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=civichero-480a3');
      console.log('   2. Click "Enable" button');
      console.log('   3. Wait 1-2 minutes for it to propagate');
      console.log('   4. Run this script again');
      console.log('\n   OR use Firebase Console (easier):');
      console.log('   https://console.firebase.google.com/project/civichero-480a3/authentication/users');
    }
    
    throw error;
  }
}

// Main function
async function main() {
  console.log('\n' + '='.repeat(60));
  console.log('⚠️  DELETE ALL AUTHENTICATION USERS');
  console.log('='.repeat(60));
  console.log('⚠️  WARNING: This will DELETE ALL authentication users!');
  console.log('='.repeat(60));
  
  // Ask for confirmation
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  
  const answer = await new Promise(resolve => {
    rl.question('\n❓ Are you sure you want to delete ALL users? (type "DELETE ALL" to confirm): ', resolve);
  });
  
  rl.close();
  
  if (answer !== 'DELETE ALL') {
    console.log('\n❌ Operation cancelled. Users were not deleted.');
    process.exit(0);
  }
  
  try {
    await clearAuthentication();
    
    console.log('\n' + '='.repeat(60));
    console.log('✅ ALL AUTHENTICATION USERS DELETED!');
    console.log('='.repeat(60));
    console.log('\n📝 Summary:');
    console.log('   ✅ Firestore: Already cleared (78 documents)');
    console.log('   ✅ Authentication: All users deleted');
    console.log('\n🎉 Your Firebase project is now completely cleared!');
    
  } catch (error) {
    console.error('\n❌ Error during deletion:', error.message);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

// Run the script
main();


