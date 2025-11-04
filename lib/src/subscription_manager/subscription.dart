import '../../signal.dart';

class Subscription {
  final Function notify;
  final _signals = <Signal>{};

  Subscription(this.notify);

  void add<T extends Object>(Signal signal) {
    if (_signals.contains(signal)) return;
    signal.connect(notify);
    _signals.add(signal);
  }

  void clear() {
    for (final signal in _signals) {
      signal.disconnect(notify);
    }
    _signals.clear();
  }
}
