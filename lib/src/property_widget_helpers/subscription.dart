import '../../signal.dart';

class Subscription {
  final _signals = <Signal>{};
  final Function rebuild;

 //remove this
  Set<Signal> get signals => _signals;

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

