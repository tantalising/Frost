import '../../signal.dart';
import 'subscription.dart';
import 'weak_map.dart';

typedef Subscriber<T extends Object> = T;
class SubscriptionManager {
  final _subscriptions = WeakMap<Subscriber, Subscription>();
  final _currentSubscribers = <Subscriber>{};
  final _alreadyTrackedSubscribers = <Subscriber>{};
  bool _tracking = false;


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
    _tracking = true;
  }

  void stopTracking(Subscriber subscriber) {
    if (!_alreadyTrackedSubscribers.contains(subscriber)) return;
    _currentSubscribers.remove(subscriber);
    _tracking = false;
  }

  void unsubscribe(Subscriber subscriber) {
    final subscription = _subscriptions.remove(subscriber);
    subscription?.clear();
  }

T connectToSubscribersOf<T extends Object>(T value, Signal signal) {
    if (!_tracking) return value;
    for (final subscriber in _currentSubscribers) {
      _subscriptions[subscriber]?.add(signal);
    }
    return value;
  }
}

