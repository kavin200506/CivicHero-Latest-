const twilio = require('twilio');
const nodemailer = require('nodemailer');
require('dotenv').config();

// Test configuration
// Set TEST_PHONE in .env file or as environment variable
// Format: +91XXXXXXXXXX (include country code)
const TEST_PHONE = process.env.TEST_PHONE || '+919876543210'; // Replace with your verified phone number
const TEST_EMAIL = process.env.TEST_EMAIL || process.env.GMAIL_USERNAME || 'test@example.com'; // Use Gmail username as default

console.log('🧪 Testing CivicHero Notification Services\n');
console.log('='.repeat(60));

// Check environment variables
console.log('\n📋 Environment Check:');
console.log('   TWILIO_ACCOUNT_SID:', process.env.TWILIO_ACCOUNT_SID ? '✅ Set' : '❌ Missing');
console.log('   TWILIO_AUTH_TOKEN:', process.env.TWILIO_AUTH_TOKEN ? '✅ Set' : '❌ Missing');
console.log('   TWILIO_PHONE_NUMBER:', process.env.TWILIO_PHONE_NUMBER || '❌ Missing');
console.log('   GMAIL_USERNAME:', process.env.GMAIL_USERNAME ? '✅ Set' : '❌ Missing');
console.log('   GMAIL_APP_PASSWORD:', process.env.GMAIL_APP_PASSWORD ? '✅ Set' : '❌ Missing');
console.log('   EMAIL_ENABLED:', process.env.EMAIL_ENABLED || 'false');

// Initialize Twilio
let twilioClient;
if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
  try {
    twilioClient = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
    console.log('\n✅ Twilio client initialized');
  } catch (error) {
    console.error('❌ Twilio initialization failed:', error.message);
  }
} else {
  console.log('\n⚠️  Twilio credentials missing, skipping SMS test');
}

// Initialize Nodemailer
let transporter;
if (process.env.GMAIL_USERNAME && process.env.GMAIL_APP_PASSWORD) {
  try {
    transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.GMAIL_USERNAME,
        pass: process.env.GMAIL_APP_PASSWORD
      }
    });
    console.log('✅ Gmail transporter initialized');
  } catch (error) {
    console.error('❌ Gmail initialization failed:', error.message);
  }
} else {
  console.log('⚠️  Gmail credentials missing, skipping Email test');
}

// Test SMS Function
async function testSMS() {
  console.log('\n' + '='.repeat(60));
  console.log('📱 Testing SMS Service (Twilio)');
  console.log('='.repeat(60));
  
  if (!twilioClient) {
    console.log('⏭️  Skipping SMS test - Twilio not initialized');
    return { success: false, error: 'Twilio not initialized' };
  }

  if (!process.env.TWILIO_PHONE_NUMBER) {
    console.log('⏭️  Skipping SMS test - TWILIO_PHONE_NUMBER not set');
    return { success: false, error: 'TWILIO_PHONE_NUMBER not set' };
  }

  const testMessage = `🧪 CivicHero Test SMS\n\nThis is a test message from CivicHero notification service. If you receive this, SMS is working correctly! ✅\n\nTime: ${new Date().toLocaleString()}`;

  try {
    console.log(`\n📤 Sending test SMS...`);
    console.log(`   From: ${process.env.TWILIO_PHONE_NUMBER}`);
    console.log(`   To: ${TEST_PHONE}`);
    console.log(`   Message: ${testMessage.substring(0, 50)}...`);

    const result = await twilioClient.messages.create({
      body: testMessage,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: TEST_PHONE
    });

    console.log(`\n✅ SMS sent successfully!`);
    console.log(`   Message SID: ${result.sid}`);
    console.log(`   Status: ${result.status}`);
    console.log(`   To: ${result.to}`);
    console.log(`   From: ${result.from}`);
    
    return { 
      success: true, 
      sid: result.sid, 
      status: result.status,
      message: 'SMS test successful'
    };
  } catch (error) {
    console.error(`\n❌ SMS test failed:`);
    console.error(`   Error Code: ${error.code}`);
    console.error(`   Error Message: ${error.message}`);
    
    if (error.code === 21211) {
      console.error(`   ⚠️  Invalid phone number format. Make sure it includes country code (e.g., +91XXXXXXXXXX)`);
    } else if (error.code === 21608) {
      console.error(`   ⚠️  Unverified phone number. You need to verify this number in Twilio console.`);
    } else if (error.code === 20003) {
      console.error(`   ⚠️  Authentication failed. Check your TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN.`);
    }
    
    return { success: false, error: error.message, code: error.code };
  }
}

// Test Email Function
async function testEmail() {
  console.log('\n' + '='.repeat(60));
  console.log('📧 Testing Email Service (Gmail)');
  console.log('='.repeat(60));
  
  if (!transporter) {
    console.log('⏭️  Skipping Email test - Gmail not initialized');
    return { success: false, error: 'Gmail not initialized' };
  }

  if (process.env.EMAIL_ENABLED !== 'true') {
    console.log('⏭️  Skipping Email test - EMAIL_ENABLED is not "true"');
    return { success: false, error: 'EMAIL_ENABLED is not true' };
  }

  const testSubject = '🧪 CivicHero Test Email';
  const testBody = `This is a test email from CivicHero notification service.

If you receive this email, the Gmail service is working correctly! ✅

Test Details:
- Time: ${new Date().toLocaleString()}
- Service: Nodemailer with Gmail SMTP
- From: ${process.env.GMAIL_USERNAME}

Thank you for using CivicHero!`;

  try {
    console.log(`\n📤 Sending test email...`);
    console.log(`   From: ${process.env.GMAIL_USERNAME}`);
    console.log(`   To: ${TEST_EMAIL}`);
    console.log(`   Subject: ${testSubject}`);

    // First, verify connection
    console.log(`\n🔍 Verifying Gmail connection...`);
    await transporter.verify();
    console.log(`✅ Gmail connection verified`);

    const mailOptions = {
      from: `"CivicHero" <${process.env.GMAIL_USERNAME}>`,
      to: TEST_EMAIL,
      subject: testSubject,
      text: testBody
    };

    const result = await transporter.sendMail(mailOptions);
    
    console.log(`\n✅ Email sent successfully!`);
    console.log(`   Message ID: ${result.messageId}`);
    console.log(`   Response: ${result.response}`);
    console.log(`   To: ${result.accepted.join(', ')}`);
    
    return { 
      success: true, 
      messageId: result.messageId,
      response: result.response,
      message: 'Email test successful'
    };
  } catch (error) {
    console.error(`\n❌ Email test failed:`);
    console.error(`   Error Code: ${error.code || 'N/A'}`);
    console.error(`   Error Message: ${error.message}`);
    
    if (error.code === 'EAUTH') {
      console.error(`   ⚠️  Authentication failed. Check your GMAIL_USERNAME and GMAIL_APP_PASSWORD.`);
      console.error(`   ⚠️  Make sure you're using an App Password, not your regular Gmail password.`);
    } else if (error.code === 'ECONNECTION') {
      console.error(`   ⚠️  Connection failed. Check your internet connection.`);
    }
    
    return { success: false, error: error.message, code: error.code };
  }
}

// Run tests
async function runTests() {
  const results = {
    sms: null,
    email: null
  };

  // Test SMS
  if (twilioClient && process.env.TWILIO_PHONE_NUMBER) {
    results.sms = await testSMS();
  }

  // Test Email
  if (transporter && process.env.EMAIL_ENABLED === 'true') {
    results.email = await testEmail();
  }

  // Summary
  console.log('\n' + '='.repeat(60));
  console.log('📊 Test Summary');
  console.log('='.repeat(60));
  console.log(`\n📱 SMS Service: ${results.sms?.success ? '✅ WORKING' : results.sms ? '❌ FAILED' : '⏭️  SKIPPED'}`);
  if (results.sms) {
    console.log(`   ${results.sms.success ? 'Message sent successfully' : `Error: ${results.sms.error}`}`);
  }
  
  console.log(`\n📧 Email Service: ${results.email?.success ? '✅ WORKING' : results.email ? '❌ FAILED' : '⏭️  SKIPPED'}`);
  if (results.email) {
    console.log(`   ${results.email.success ? 'Email sent successfully' : `Error: ${results.email.error}`}`);
  }

  console.log('\n' + '='.repeat(60));
  
  // Exit with appropriate code
  const allPassed = (results.sms === null || results.sms?.success) && 
                    (results.email === null || results.email?.success);
  process.exit(allPassed ? 0 : 1);
}

// Run the tests
runTests().catch(error => {
  console.error('\n❌ Test runner error:', error);
  process.exit(1);
});

