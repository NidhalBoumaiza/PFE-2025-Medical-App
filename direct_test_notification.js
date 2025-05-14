/**
 * Direct test script for sending a notification using Firebase Admin SDK
 *
 * Usage:
 * 1. Save this file as direct_test_notification.js in the salma-mailer folder
 * 2. Make sure serviceAccountKey.json is in the same folder
 * 3. Run it with Node.js: node direct_test_notification.js
 * 4. Make sure to replace the FCM_TOKEN with an actual token from your app
 */

const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
try {
  admin.initializeApp({
    credential: admin.credential.cert(
      require("./serviceAccountKey.json")
    ),
    databaseURL: "https://medicalapp-f1951.firebaseio.com",
  });
} catch (error) {
  console.error("Firebase Admin initialization error:", error);
  process.exit(1);
}

// Replace with your FCM token from the Flutter app
const FCM_TOKEN = "PASTE_YOUR_FCM_TOKEN_HERE";

// Function to send a test notification
async function sendTestNotification() {
  try {
    // Message with both notification and data payloads
    const message = {
      token: FCM_TOKEN,
      notification: {
        title: "Direct Test Notification",
        body: "This notification was sent directly using Firebase Admin SDK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          priority: "high",
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
      data: {
        type: "newAppointment",
        senderId: "test_sender_id",
        recipientId: "test_recipient_id",
        title: "Direct Test Notification",
        body: "This notification was sent directly using Firebase Admin SDK",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    console.log("Sending notification...");
    const response = await admin.messaging().send(message);

    console.log("Successfully sent notification:", response);

    // Also save to Firestore for persistence
    await admin.firestore().collection("notifications").add({
      title: message.notification.title,
      body: message.notification.body,
      senderId: message.data.senderId,
      recipientId: message.data.recipientId,
      type: message.data.type,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
    });

    console.log("Notification saved to Firestore");
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

// Execute the function
sendTestNotification()
  .then(() => console.log("Test completed"))
  .catch((error) => console.error("Test failed:", error))
  .finally(() => process.exit(0));
