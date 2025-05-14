const catchAsync = require("../utils/catchAsync");
const AppError = require("../utils/appError");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
// You need to add a serviceAccountKey.json file to your project
// This file can be downloaded from Firebase Console > Project Settings > Service accounts
try {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(
        require("../serviceAccountKey.json")
      ),
      databaseURL: "https://medicalapp-f1951.firebaseio.com", // Updated to match your Firebase project ID
    });
  }
} catch (error) {
  console.error("Firebase Admin initialization error:", error);
}

exports.sendNotification = catchAsync(async (req, res, next) => {
  const { token, title, body, data, notification } = req.body;

  if (!token) {
    return next(new AppError("FCM token is required", 400));
  }

  // Check for either direct title/body or notification object
  if (
    (!title || !body) &&
    (!notification || !notification.title || !notification.body)
  ) {
    return next(
      new AppError("Notification title and body are required", 400)
    );
  }

  try {
    // Prepare the message with notification payload
    const message = {
      token,
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
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
    };

    // Use provided notification object or create one from title/body
    if (notification) {
      message.notification = notification;
    } else if (title && body) {
      message.notification = {
        title,
        body,
      };
    }

    // Add data payload if provided
    if (data) {
      message.data = data;
    }

    console.log(
      "Sending FCM message:",
      JSON.stringify(message, null, 2)
    );
    const response = await admin.messaging().send(message);

    console.log("Successfully sent notification:", response);

    // Save notification to Firestore for persistence if it has recipient info
    if (data && data.recipientId && data.senderId) {
      try {
        await admin
          .firestore()
          .collection("notifications")
          .add({
            title:
              message.notification?.title ||
              data.title ||
              "New Notification",
            body: message.notification?.body || data.body || "",
            senderId: data.senderId,
            recipientId: data.recipientId,
            type: data.type || "general",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            isRead: false,
            ...(data.appointmentId && {
              appointmentId: data.appointmentId,
            }),
            ...(data.prescriptionId && {
              prescriptionId: data.prescriptionId,
            }),
          });
        console.log("Notification saved to Firestore");
      } catch (firestoreError) {
        console.error("Error saving to Firestore:", firestoreError);
      }
    }

    res.status(200).json({
      status: "success",
      message: "Notification sent successfully",
      response,
    });
  } catch (error) {
    console.error("Error sending notification:", error);
    return next(new AppError("Failed to send notification", 500));
  }
});

exports.saveNotificationToFirestore = catchAsync(
  async (req, res, next) => {
    const {
      title,
      body,
      senderId,
      recipientId,
      type,
      appointmentId,
      prescriptionId,
    } = req.body;

    if (!title || !body || !senderId || !recipientId || !type) {
      return next(
        new AppError("Missing required notification fields", 400)
      );
    }

    try {
      const notificationData = {
        title,
        body,
        senderId,
        recipientId,
        type,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
      };

      // Add optional fields if provided
      if (appointmentId)
        notificationData.appointmentId = appointmentId;
      if (prescriptionId)
        notificationData.prescriptionId = prescriptionId;

      const result = await admin
        .firestore()
        .collection("notifications")
        .add(notificationData);

      res.status(201).json({
        status: "success",
        message: "Notification saved to Firestore",
        notificationId: result.id,
      });
    } catch (error) {
      console.error("Error saving notification to Firestore:", error);
      return next(new AppError("Failed to save notification", 500));
    }
  }
);
