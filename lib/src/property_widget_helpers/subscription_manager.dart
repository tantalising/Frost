import 'package:flutter/material.dart' show State;
import 'subscription.dart';
import '../../property_widget.dart';

import 'weak_map.dart';

class SubscriptionManager {
  static final SubscriptionManager _instance =
      SubscriptionManager._internal();
  final _repositories = WeakMap<State<PropertyWidget>, Subscription>();
  final _currentSubscribers = <State<PropertyWidget>>{};
  final _alreadyTrackedSubscribers = <State<PropertyWidget>>{};

  SubscriptionManager._internal();
  factory SubscriptionManager() {
    return _instance;
  }

  void openRepo(State<PropertyWidget> subscriber, Function rebuild) {
    if (_repositories.containsKey(subscriber)) return;
    _repositories[subscriber] = Subscription(rebuild);
  }

  void subscribe(State<PropertyWidget> subscriber) {
    if (_alreadyTrackedSubscribers.contains(subscriber)) return;
    print('I am subscribing: ${subscriber.widget.debugString}');
    _currentSubscribers.add(subscriber);
    _alreadyTrackedSubscribers.add(subscriber);
  }

  void unsubscribe(State<PropertyWidget> subscriber) {
    print('my(name: ${subscriber.widget.debugString}) subscriptions are ${_repositories[subscriber]?.signals}');
    _currentSubscribers.remove(subscriber);
  }

  Set<State<PropertyWidget>> subscribers() {
    return Set.unmodifiable(_currentSubscribers);
  }

  Subscription? getRepo(State<PropertyWidget> subscriber) {
    return _repositories[subscriber];
  }

  void closeRepo(State<PropertyWidget> subscriber) {
    final repo = _repositories.remove(subscriber);
    repo?.clear();
  }
}
