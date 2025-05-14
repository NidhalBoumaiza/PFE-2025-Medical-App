# Setting Up Firebase Notifications with Express Backend

This guide will help you set up Firebase Cloud Messaging (FCM) for
your MediLink application to enable push notifications.

## Step 1: Get Firebase Admin SDK Credentials

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (medicalapp-f1951)
3. Navigate to Project Settings (gear icon) > Service accounts
4. Click "Generate new private key"
5. Download the JSON file and save it as `serviceAccountKey.json` in
   the root directory of your Express app (salma-mailer)

## Step 2: Install Firebase Admin SDK in Express App

1. Make sure you've installed the Firebase Admin SDK by running:
   ```bash
   cd salma-mailer
   npm install firebase-admin
   ```

## Step 3: Update Firebase Configuration

1. In your Flutter app, we're now using the Firebase options from the
   generated file:

   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform
   );
   ```

2. In your Express app, the Firebase Admin initialization has been
   updated to:
   ```javascript
   admin.initializeApp({
     credential: admin.credential.cert(
       require("../serviceAccountKey.json")
     ),
     databaseURL: "https://medicalapp-f1951.firebaseio.com",
   });
   ```

## Step 4: Express API Endpoint

In your Flutter app, the API endpoint has been updated to:

```dart
static const String baseUrl = 'http://192.168.1.18:3000/api/v1';
```

## Step 5: Configure Android for FCM

1. Make sure your `AndroidManifest.xml` contains the necessary
   permissions and service declarations:

   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.VIBRATE" />
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

   <application ...>
     <meta-data
         android:name="com.google.firebase.messaging.default_notification_channel_id"
         android:value="high_importance_channel" />

     <meta-data
         android:name="com.google.firebase.messaging.default_notification_icon"
         android:resource="@mipmap/ic_launcher" />
   </application>
   ```

## Step 6: Configure iOS for FCM

1. Update your `Info.plist` to include:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
     <string>fetch</string>
     <string>remote-notification</string>
   </array>
   <key>FirebaseAppDelegateProxyEnabled</key>
   <string>NO</string>
   ```

## Step 7: Update Firestore Security Rules

Make sure your Firestore security rules allow reading and writing
notifications:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notifications/{notificationId} {
      allow read: if request.auth != null && resource.data.recipientId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null && resource.data.recipientId == request.auth.uid;
      allow delete: if request.auth != null && resource.data.recipientId == request.auth.uid;
    }

    // Other rules for your app...
  }
}
```

## Step 8: Start the Express Server

1. Start your Express server:
   ```bash
   cd salma-mailer
   npm start
   ```

## Step 9: Test Notifications

1. Get the FCM token from a logged-in user:

   - The app now automatically prints the FCM token in the console
     logs when a user logs in
   - Look for "FCM Token: ..." in your Flutter app logs

2. Use the test script to send a notification:

   ```bash
   # Edit the test_notification.js file to add your FCM token
   # Then run:
   node test_notification.js
   ```

3. Or send a test notification using a REST client:

   ```http
   POST http://192.168.1.18:3000/api/v1/notifications/send
   Content-Type: application/json

   {
     "token": "YOUR_FCM_TOKEN_FROM_LOGS",
     "title": "Test Notification",
     "body": "This is a test notification",
     "data": {
       "type": "newAppointment",
       "senderId": "sender_user_id",
       "recipientId": "recipient_user_id"
     }
   }
   ```

## Troubleshooting

- **Notifications not appearing on Android**:

  - Check that the device is not in battery optimization mode
  - Verify the notification channel is properly created
  - Check logcat for FCM-related errors

- **Notifications not appearing on iOS**:

  - Ensure your app has proper provisioning profiles with push
    entitlements
  - Verify background modes are enabled in app capabilities
  - Check the device console logs for FCM-related errors

- **Express server errors**:

  - Check that your `serviceAccountKey.json` is valid and in the
    correct location
  - Verify that Firebase Admin SDK is properly initialized
  - Check server logs for errors

- **Firestore permission errors**:
  - Verify that your security rules allow saving notifications
  - Check user authentication status
