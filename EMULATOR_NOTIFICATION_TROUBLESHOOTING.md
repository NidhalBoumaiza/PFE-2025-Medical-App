# Troubleshooting FCM Notifications on Android Emulators

This guide provides steps to troubleshoot and fix issues with Firebase
Cloud Messaging (FCM) notifications not appearing on Android
emulators.

## Common Issues with Emulators

Android emulators often have issues displaying notifications due to:

1. Missing Google Play Services
2. Notification channel configuration
3. Notification permission settings
4. Background restrictions

## Step 1: Verify Google Play Services

Make sure your emulator has Google Play Services installed:

1. Create a new emulator with the "Google Play" option enabled
2. Use an emulator with API level 30+ (Android 11+) for best
   compatibility
3. Verify in the emulator settings that Google Play Services is
   installed and updated

## Step 2: Check Notification Permissions

1. Open the emulator
2. Go to Settings > Apps > Your App > Permissions
3. Make sure Notifications permission is granted
4. Also check Settings > Apps > Your App > Notifications and ensure
   they are enabled

## Step 3: Verify FCM Token

1. Check your app logs for the FCM token
2. Make sure the token is being printed with: `FCM Token: <token>`
3. Verify the token is being saved to Firestore in the user document

## Step 4: Test Direct Notification

Use the direct_test_notification.js script to send a notification
directly:

```bash
cd salma-mailer
# Edit direct_test_notification.js to add your FCM token
node direct_test_notification.js
```

## Step 5: Check Notification Channel

1. In your app, make sure the notification channel is being created
   with maximum importance:

   ```dart
   const AndroidNotificationChannel channel = AndroidNotificationChannel(
     'high_importance_channel',
     'High Importance Notifications',
     description: 'This channel is used for important notifications.',
     importance: Importance.max,
     playSound: true,
     enableVibration: true,
     showBadge: true,
   );
   ```

2. Verify in the emulator:
   - Go to Settings > Apps > Your App > Notifications
   - Check that the "High Importance Notifications" channel exists and
     is enabled

## Step 6: Debug Notification Reception

Add these debug statements to your app and check the logs:

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
});
```

## Step 7: Test with Both Notification and Data Payload

When testing notifications, include both notification and data
payloads:

```javascript
const message = {
  token: FCM_TOKEN,
  notification: {
    title: "Test Notification",
    body: "This is a test notification",
  },
  data: {
    type: "newAppointment",
    title: "Test Notification", // Duplicate in data
    body: "This is a test notification", // Duplicate in data
  },
};
```

## Step 8: Check Firestore for Saved Notifications

1. Open the Firebase Console
2. Go to Firestore Database
3. Check the 'notifications' collection
4. Verify that notifications are being saved correctly

## Step 9: Restart the Emulator

Sometimes simply restarting the emulator can fix notification issues:

1. Stop the emulator
2. Cold boot the emulator (not quick boot)
3. Run your app again

## Step 10: Use a Physical Device

If all else fails, test on a physical device:

1. Install your app on a physical Android device
2. Make sure the device has Google Play Services
3. Test notifications using the same scripts

## Additional Troubleshooting

- Check Android logs using `adb logcat | grep FCM`
- Make sure your app is not in battery optimization mode
- Verify that the notification icon is properly set
- Try sending a notification from the Firebase Console directly
