import '../../signal.dart';
import 'subscription.dart';
import 'weak_map.dart';

typedef Subscriber<T extends Object> = T;
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
    if (!_alreadyTrackedSubscribers.contains(subscriber)) return;
    _currentSubscribers.remove(subscriber);
  }

  void unsubscribe(Subscriber subscriber) {
    final subscription = _subscriptions.remove(subscriber);
    subscription?.clear();
  }

T connectToSubscribersOf<T extends Object>(T value, Signal signal) {
    final noSubscriberExists = _currentSubscribers.isEmpty;
    if (noSubscriberExists) return value;
    for (final subscriber in _currentSubscribers) {
      _subscriptions[subscriber]?.add(signal);
    }
    return value;
  }
}

