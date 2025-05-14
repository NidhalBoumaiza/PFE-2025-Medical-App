/**
 * Test script for sending a notification using the Express API
 *
 * Usage:
 * 1. Save this file as test_notification.js
 * 2. Run it with Node.js: node test_notification.js
 * 3. Make sure to replace the FCM_TOKEN with an actual token from your app
 */

const http = require("http");

// Replace with your FCM token from the Flutter app
// You can get this by checking the console logs in your Flutter app
// Look for "FCM Token: <token>" in the logs
const FCM_TOKEN = "PASTE_YOUR_FCM_TOKEN_HERE";

// Replace with the user IDs from your Firebase database
const SENDER_ID = "test_sender_id";
const RECIPIENT_ID = "test_recipient_id";

// Enhanced notification data with both notification and data payloads
const notificationData = {
  token: FCM_TOKEN,
  title: "Test Notification",
  body: "This is a test notification from the Express server",
  // Include notification payload for foreground display
  notification: {
    title: "Test Notification",
    body: "This is a test notification from the Express server",
    android_channel_id: "high_importance_channel",
  },
  data: {
    type: "newAppointment",
    senderId: SENDER_ID,
    recipientId: RECIPIENT_ID,
    title: "Test Notification", // Duplicate in data for handling without notification payload
    body: "This is a test notification from the Express server", // Duplicate in data
    click_action: "FLUTTER_NOTIFICATION_CLICK",
  },
};

// Options for the HTTP request
const options = {
  hostname: "192.168.1.18",
  port: 3000,
  path: "/api/v1/notifications/send",
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Content-Length": Buffer.byteLength(
      JSON.stringify(notificationData)
    ),
  },
};

// Send the HTTP request
const req = http.request(options, (res) => {
  console.log(`STATUS: ${res.statusCode}`);
  console.log(`HEADERS: ${JSON.stringify(res.headers)}`);

  let data = "";

  res.on("data", (chunk) => {
    data += chunk;
  });

  res.on("end", () => {
    console.log("Response body:", data);
    if (res.statusCode === 200) {
      console.log("Notification sent successfully!");
    } else {
      console.log("Failed to send notification.");
    }
  });
});

req.on("error", (e) => {
  console.error(`Problem with request: ${e.message}`);
});

// Write the request body
req.write(JSON.stringify(notificationData));
req.end();

console.log("Sending notification request...");
