import 'package:flutter/material.dart' show State;
import '../../signal.dart';
import 'subscription.dart';
import '../../watcher.dart';

import 'weak_map.dart';

typedef Subscriber = State<Watcher>;
class SubscriptionManager {
  final _subscriptions = WeakMap<Subscriber, Subscription>();
  final _currentSubscribers = <Subscriber>{};
  final _alreadyTrackedSubscribers = <Subscriber>{};


  SubscriptionManager._internal();
  static final SubscriptionManager _instance =
  SubscriptionManager._internal();
  factory SubscriptionManager() {
    return _instance;
  }

  void subscribe(Subscriber subscriber, Function rebuild) {
    if (_subscriptions.containsKey(subscriber)) return;
    _subscriptions[subscriber] = Subscription(rebuild);
  }

  void startTracking(Subscriber subscriber) {
    if (_alreadyTrackedSubscribers.contains(subscriber)) return;
    _currentSubscribers.add(subscriber);
    _alreadyTrackedSubscribers.add(subscriber);
  }

  void stopTracking(Subscriber subscriber) {
    _currentSubscribers.remove(subscriber);
  }

  Set<Subscriber> subscribers() {
    return Set.unmodifiable(_currentSubscribers);
  }

  Subscription? subscription(Subscriber subscriber) {
    return _subscriptions[subscriber];
  }

  void unsubscribe(Subscriber subscriber) {
    final subscription = _subscriptions.remove(subscriber);
    subscription?.clear();
  }

T connectToSubscribersOf<T extends Object>(T value, Signal signal) {
    final manager = SubscriptionManager();
    for (final subscriber in manager.subscribers()) {
      final subscriptions = manager.subscription(subscriber);
      subscriptions?.add(signal);
    }
    return value;
  }
}
