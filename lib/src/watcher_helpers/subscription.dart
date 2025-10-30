import '../../signal.dart';

class Subscription {
  final Function rebuild;
  final _signals = <Signal>{};

  Subscription(this.rebuild);

  void add<T extends Object>(Signal signal) {
    if (_signals.contains(signal)) return;
    signal.connect(rebuild);
    _signals.add(signal);
  }

  void clear() {
    for (final signal in _signals) {
      signal.disconnect(rebuild);
    }
    _signals.clear();
  }
}
