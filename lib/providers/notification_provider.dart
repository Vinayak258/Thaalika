import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  String? _fcmToken;

  NotificationProvider(this._notificationService);

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    await _notificationService.initialize();
    _fcmToken = await _notificationService.getToken();
    notifyListeners();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }
}
