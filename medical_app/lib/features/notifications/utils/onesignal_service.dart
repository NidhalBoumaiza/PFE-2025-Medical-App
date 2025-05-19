import 'package:dartz/dartz.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../core/error/exceptions.dart';

class OneSignalService {
  final OneSignal _oneSignal;

  OneSignalService({OneSignal? oneSignal}) : _oneSignal = oneSignal ?? OneSignal.shared;

  /// Initialize OneSignal with your app ID
  Future<void> init() async {
    await _oneSignal.setAppId(AppConstants.oneSignalAppId);
    
    // Enable debug logs - remove in production
    await _oneSignal.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    
    // Request permission to send push notifications
    await _oneSignal.promptUserForPushNotificationPermission();
    
    // Handle notification opened events
    _oneSignal.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // Handle notification opened
      print('Notification opened: ${result.notification.notificationId}');
      
      // Handle additional data
      if (result.notification.additionalData != null) {
        print('Additional data: ${result.notification.additionalData}');
        // You can navigate to specific screens based on this data
      }
    });
    
    // Handle notification received in foreground
    _oneSignal.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
      // Complete the event to display the notification or prevent it from displaying
      event.complete(event.notification);
      
      print('Notification received in foreground: ${event.notification.notificationId}');
    });
  }

  /// Get OneSignal player ID (device token)
  Future<String?> getPlayerId() async {
    try {
      final deviceState = await _oneSignal.getDeviceState();
      final playerId = deviceState?.userId;
      
      if (playerId != null) {
        // Save the player ID to SharedPreferences for future use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ONESIGNAL_PLAYER_ID', playerId);
      }
      
      return playerId;
    } catch (e) {
      print('Error getting OneSignal player ID: $e');
      return null;
    }
  }

  /// Save OneSignal player ID to backend
  Future<Unit> savePlayerIdToBackend(String userId) async {
    try {
      final playerId = await getPlayerId();
      if (playerId == null) {
        throw ServerException(message: 'Failed to get OneSignal player ID');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('TOKEN');
      
      if (token == null) {
        throw ServerException(message: 'Authentication token not found');
      }
      
      // TODO: Update this to use the appropriate API endpoint from your backend
      // For now, we'll just return Unit since the actual implementation depends on your backend
      
      return unit;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to save OneSignal player ID: $e');
    }
  }

  /// Set external user ID (your app's user ID)
  Future<void> setExternalUserId(String userId) async {
    try {
      await _oneSignal.setExternalUserId(userId);
    } catch (e) {
      print('Error setting external user ID: $e');
    }
  }

  /// Add tags to the user (for segmentation)
  Future<void> addTags(Map<String, dynamic> tags) async {
    try {
      await _oneSignal.sendTags(tags);
    } catch (e) {
      print('Error adding tags: $e');
    }
  }

  /// Remove tags from the user
  Future<void> removeTags(List<String> tagKeys) async {
    try {
      await _oneSignal.deleteTags(tagKeys);
    } catch (e) {
      print('Error removing tags: $e');
    }
  }

  /// Logout - clear external user ID
  Future<void> logout() async {
    try {
      await _oneSignal.removeExternalUserId();
    } catch (e) {
      print('Error during OneSignal logout: $e');
    }
  }
} 