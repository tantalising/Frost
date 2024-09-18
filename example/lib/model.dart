import 'package:flutter_signal/signal_model.dart';

class CountModel extends SignalModel {
  static final countChanged = Signal();
  var _count = 0;

  int get count => _count;
  void incrementCount() {
    _count++;
  }

  @override
  void init() {
    // init something here
    super.init();
  }

  @override
  void dispose() {
    // dispose something here.
    super.dispose();
  }
}


