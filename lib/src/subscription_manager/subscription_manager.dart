import 'dart:ui';
import '../../signal.dart';

abstract class SubscriptionManager {
  static VoidCallback? _activeSubscription;

  static void initiateSubscription(VoidCallback subscription) {
    if (_activeSubscription != null) return;
    _activeSubscription = subscription;
  }

  static void finalizeSubscription() {
    _activeSubscription = null;
  }

  static T connectToSubscribersOf<T>(T value, Signal signal) {
    if (_activeSubscription == null) return value;
    signal.connect(_activeSubscription!);
    return value;
  }
}