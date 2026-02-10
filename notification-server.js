const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const twilio = require('twilio');
const nodemailer = require('nodemailer');
require('dotenv').config();

const app = express();
// Enable CORS for all origins (for development)
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Log all requests for debugging
app.use((req, res, next) => {
  console.log(`\n${new Date().toISOString()} - ${req.method} ${req.path}`);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('   Request Body:', JSON.stringify(req.body, null, 2));
  }
  next();
});

// Initialize Firebase Admin
if (!admin.apps.length) {
  const serviceAccount = require('./service-account-key.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

// Initialize Twilio
const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// Initialize Nodemailer for Gmail
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USERNAME,
    pass: process.env.GMAIL_APP_PASSWORD
  }
});

// Helper function to get status message
function getStatusMessage(status, department, issueType) {
  const deptName = department || 'the department';
  const issue = issueType || 'your complaint';
  
  switch (status.toLowerCase()) {
    case 'assigned':
      return {
        sms: `Your complaint "${issue}" has been assigned to ${deptName}. We'll keep you updated on the progress.`,
        email: {
          subject: `Complaint Assigned - ${issue}`,
          body: `Dear Citizen,\n\nYour complaint "${issue}" has been assigned to ${deptName}.\n\nWe will keep you updated on the progress.\n\nThank you for using CivicHero.\n\nBest regards,\nCivicHero Team`
        }
      };
    case 'in progress':
      return {
        sms: `Good news! Your complaint "${issue}" is now In Progress by ${deptName}. We're working on resolving it.`,
        email: {
          subject: `Complaint In Progress - ${issue}`,
          body: `Dear Citizen,\n\nGreat news! Your complaint "${issue}" is now In Progress by ${deptName}.\n\nOur team is actively working on resolving your issue. We'll notify you once it's completed.\n\nThank you for your patience.\n\nBest regards,\nCivicHero Team`
        }
      };
    case 'resolved':
    case 'completed':
      return {
        sms: `🎉 Your complaint "${issue}" has been marked as Resolved by ${deptName}. Thank you for using CivicHero!`,
        email: {
          subject: `Complaint Resolved - ${issue}`,
          body: `Dear Citizen,\n\nWe're pleased to inform you that your complaint "${issue}" has been successfully resolved by ${deptName}.\n\nThank you for using CivicHero and helping us improve our community!\n\nIf you have any feedback, please don't hesitate to reach out.\n\nBest regards,\nCivicHero Team`
        }
      };
    default:
      return {
        sms: `Your complaint "${issue}" status has been updated to ${status} by ${deptName}.`,
        email: {
          subject: `Complaint Status Update - ${issue}`,
          body: `Dear Citizen,\n\nYour complaint "${issue}" status has been updated to ${status} by ${deptName}.\n\nThank you for using CivicHero.\n\nBest regards,\nCivicHero Team`
        }
      };
  }
}

// Send SMS via Twilio
async function sendSMS(phoneNumber, message) {
  try {
    const result = await twilioClient.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: phoneNumber
    });
    console.log(`✅ SMS sent to ${phoneNumber}: ${result.sid}`);
    return { success: true, sid: result.sid };
  } catch (error) {
    console.error(`❌ SMS failed to ${phoneNumber}:`, error.message);
    return { success: false, error: error.message };
  }
}

// Send Email via Gmail
async function sendEmail(email, subject, body) {
  if (process.env.EMAIL_ENABLED !== 'true') {
    console.log('📧 Email disabled, skipping...');
    return { success: true, skipped: true };
  }

  try {
    const mailOptions = {
      from: `"CivicHero" <${process.env.GMAIL_USERNAME}>`,
      to: email,
      subject: subject,
      text: body
    };

    const result = await transporter.sendMail(mailOptions);
    console.log(`✅ Email sent to ${email}: ${result.messageId}`);
    return { success: true, messageId: result.messageId };
  } catch (error) {
    console.error(`❌ Email failed to ${email}:`, error.message);
    return { success: false, error: error.message };
  }
}

// Main notification endpoint
app.post('/notify-status-change', async (req, res) => {
  try {
    console.log('📥 Received notification request:', JSON.stringify(req.body, null, 2));
    
    const { complaintId, userId, newStatus, department, issueType } = req.body;

    if (!complaintId || !userId || !newStatus) {
      console.error('❌ Missing required fields:', { complaintId, userId, newStatus });
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: complaintId, userId, newStatus'
      });
    }

    console.log(`📬 Processing notification for complaint ${complaintId}:`);
    console.log(`   User ID: ${userId}`);
    console.log(`   New Status: ${newStatus}`);
    console.log(`   Department: ${department || 'Unknown'}`);
    console.log(`   Issue Type: ${issueType || 'Unknown'}`);

    // Only send notifications for specific statuses (case-insensitive)
    const notifyStatuses = ['assigned', 'in progress', 'resolved', 'completed'];
    const statusLower = newStatus.toLowerCase().trim();
    if (!notifyStatuses.includes(statusLower)) {
      console.log(`⏭️  Status "${newStatus}" (normalized: "${statusLower}") not in notification list, skipping...`);
      return res.json({ success: true, skipped: true, reason: 'Status not in notification list' });
    }

    // Fetch user profile from Firestore
    console.log(`🔍 Fetching user profile for userId: ${userId}`);
    console.log(`   Document path: users/${userId}`);
    
    const userDoc = await db.collection('users').doc(userId).get();
    console.log(`   Document exists: ${userDoc.exists}`);
    console.log(`   Document ID: ${userDoc.id}`);
    
    if (userDoc.exists) {
      console.log(`   Document data keys:`, Object.keys(userDoc.data() || {}));
    }
    
    let phoneNumber = '';
    let email = '';
    let userName = 'Citizen';

    if (!userDoc.exists) {
      console.error(`❌ Document does not exist at path: users/${userId}`);
      console.log(`   Trying to list all users to debug...`);
      
      // Debug: Try to list a few users to see if collection is accessible
      try {
        const allUsers = await db.collection('users').limit(5).get();
        console.log(`   Found ${allUsers.size} users in collection`);
        allUsers.forEach(doc => {
          console.log(`   - User ID: ${doc.id} (exists: ${doc.id === userId ? 'THIS ONE!' : 'no'})`);
        });
      } catch (listError) {
        console.error(`   Could not list users: ${listError.message}`);
      }
      console.warn(`⚠️  User profile not found in Firestore for userId: ${userId}`);
      console.log(`🔍 Attempting to get email from Firebase Auth...`);
      
      // Try to get user email from Firebase Auth as fallback
      try {
        const authUser = await admin.auth().getUser(userId);
        email = authUser.email || '';
        userName = authUser.displayName || authUser.email?.split('@')[0] || 'Citizen';
        console.log(`✅ Found email from Auth: ${email}`);
      } catch (authError) {
        console.error(`❌ Could not fetch user from Auth: ${authError.message}`);
        
        // Last resort: Try to find email in the complaint itself or use a default
        // Check if we can find the user's email from other sources
        console.log(`🔍 Searching for user email in other collections...`);
        
        // Try to find email from issues collection (if stored there)
        try {
          const issueDoc = await db.collection('issues').doc(complaintId).get();
          if (issueDoc.exists) {
            const issueData = issueDoc.data();
            // Some apps store email in the issue document
            if (issueData?.user_email) {
              email = issueData.user_email;
              console.log(`✅ Found email in issue document: ${email}`);
            }
          }
        } catch (issueError) {
          console.warn(`⚠️  Could not check issue document: ${issueError.message}`);
        }
        
        // If still no email, return error but with helpful message
        if (!email) {
          return res.status(404).json({
            success: false,
            error: 'User profile not found. User may have been deleted or needs to complete profile.',
            userId: userId,
            suggestion: 'Please ensure the user exists in Firebase Auth and has completed their profile in the app'
          });
        }
      }
    } else {
      const userData = userDoc.data();
      console.log(`📋 User data keys:`, Object.keys(userData || {}));
      phoneNumber = userData?.phonenumber || userData?.phoneNumber || '';
      email = userData?.email || ''; // Get from Firestore first
      userName = userData?.fullName || 'Citizen';

      // Clean up phone number - add country code if missing
      if (phoneNumber && !phoneNumber.startsWith('+')) {
        // If phone number doesn't start with +, assume it's Indian (+91)
        // You can modify this logic based on your needs
        if (phoneNumber.length === 10) {
          phoneNumber = '+91' + phoneNumber;
          console.log(`📞 Added country code to phone: ${phoneNumber}`);
        }
      }

      // If email is empty or missing from profile, try to get from Auth
      if (!email || email.trim() === '') {
        console.log(`📧 Email is empty in profile, trying Firebase Auth...`);
        try {
          const authUser = await admin.auth().getUser(userId);
          email = authUser.email || '';
          if (email) {
            console.log(`✅ Found email from Auth: ${email}`);
          } else {
            console.warn(`⚠️  Email also not found in Auth`);
          }
        } catch (authError) {
          console.warn(`⚠️  Could not fetch email from Auth: ${authError.message}`);
        }
      } else {
        console.log(`✅ Found email in profile: ${email}`);
      }
    }

    console.log(`📞 Phone: ${phoneNumber ? `Found (${phoneNumber})` : 'Missing'}`);
    console.log(`📧 Email: ${email ? `Found (${email})` : 'Missing'}`);

    if (!phoneNumber && !email) {
      console.error(`⚠️  No phone or email found for user: ${userId}`);
      return res.status(400).json({
        success: false,
        error: 'User has no phone number or email. Please complete profile in the app.',
        userId: userId
      });
    }

    // Get status message
    const messages = getStatusMessage(newStatus, department, issueType);

    // Send notifications
    const results = {
      sms: null,
      email: null
    };

    // Send SMS
    if (phoneNumber) {
      console.log(`📱 Sending SMS to ${phoneNumber}...`);
      console.log(`   Message: ${messages.sms}`);
      results.sms = await sendSMS(phoneNumber, messages.sms);
    } else {
      console.log(`⏭️  No phone number, skipping SMS...`);
    }

    // Send Email
    if (email) {
      console.log(`📧 Sending email to ${email}...`);
      console.log(`   Subject: ${messages.email.subject}`);
      results.email = await sendEmail(email, messages.email.subject, messages.email.body);
    } else {
      console.log(`⏭️  No email, skipping email...`);
    }

    console.log(`✅ Notification process completed`);
    console.log(`   SMS Result:`, results.sms);
    console.log(`   Email Result:`, results.email);

    res.json({
      success: true,
      message: 'Notifications sent successfully',
      results: results
    });

  } catch (error) {
    console.error('❌ Error in notification service:', error);
    console.error('   Stack:', error.stack);
    res.status(500).json({
      success: false,
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'CivicHero Notification Service' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 CivicHero Notification Service running on port ${PORT}`);
  console.log(`📱 Twilio: ${process.env.TWILIO_ACCOUNT_SID ? '✅ Configured' : '❌ Not configured'}`);
  console.log(`📧 Email: ${process.env.EMAIL_ENABLED === 'true' ? '✅ Enabled' : '❌ Disabled'}`);
});

