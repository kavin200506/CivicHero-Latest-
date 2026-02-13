const admin = require('firebase-admin');
require('dotenv').config();

// Initialize Firebase Admin
if (!admin.apps.length) {
  const serviceAccount = require('./service-account-key.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();
const userId = 'bGXdBCQH2SQ1yZk0QJD4mZb8oiL2';

async function testUserAccess() {
  console.log('🔍 Testing access to user document...');
  console.log(`   User ID: ${userId}`);
  console.log(`   Document path: users/${userId}\n`);

  try {
    // Test 1: Try to get the specific document
    console.log('📋 Test 1: Getting specific document...');
    const userDoc = await db.collection('users').doc(userId).get();
    console.log(`   Document exists: ${userDoc.exists}`);
    console.log(`   Document ID: ${userDoc.id}`);
    
    if (userDoc.exists) {
      const data = userDoc.data();
      console.log(`   ✅ Document found!`);
      console.log(`   Data keys:`, Object.keys(data || {}));
      console.log(`   Email: ${data?.email || 'MISSING'}`);
      console.log(`   Phone: ${data?.phonenumber || data?.phoneNumber || 'MISSING'}`);
      console.log(`   Full Name: ${data?.fullName || 'MISSING'}`);
    } else {
      console.log(`   ❌ Document does not exist`);
    }

    // Test 2: List all users to see what's there
    console.log('\n📋 Test 2: Listing all users in collection...');
    const allUsers = await db.collection('users').limit(10).get();
    console.log(`   Found ${allUsers.size} users:`);
    
    allUsers.forEach(doc => {
      const isMatch = doc.id === userId;
      console.log(`   ${isMatch ? '✅' : '  '} ${doc.id} ${isMatch ? '<-- THIS ONE!' : ''}`);
      if (isMatch) {
        const data = doc.data();
        console.log(`      Email: ${data?.email || 'MISSING'}`);
        console.log(`      Phone: ${data?.phonenumber || data?.phoneNumber || 'MISSING'}`);
      }
    });

    // Test 3: Try to query by a field
    console.log('\n📋 Test 3: Searching for user with fullName "KAVIN"...');
    const queryResult = await db.collection('users')
      .where('fullName', '==', 'KAVIN')
      .limit(5)
      .get();
    
    console.log(`   Found ${queryResult.size} users with name "KAVIN":`);
    queryResult.forEach(doc => {
      console.log(`   - ${doc.id}`);
      if (doc.id === userId) {
        console.log(`     ✅ This matches the userId we're looking for!`);
      }
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('   Stack:', error.stack);
  }

  process.exit(0);
}

testUserAccess();





