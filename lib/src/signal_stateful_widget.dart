import 'package:flutter/material.dart';
import 'package:flutter_signal/signal.dart';

/// A widget that automatically rebuilds whenever one of the signals
/// in [SignalStateFulWidget.signals] is emitted.
///
/// This is a convenience widget that should be used in place of a StatefulWidget when you have to connect and
/// disconnect some signals in a stateful widget's initState and dispose methods.

abstract class SignalStatefulWidget extends StatefulWidget {
  const SignalStatefulWidget({super.key});

  @override
  SignalState createState();
}

abstract class SignalState<T extends SignalStatefulWidget> extends State<T> {

  Set<Signal> signals();

  @override
  void initState() {
    for (final signal in signals()) {
      signal.connect(_rebuild);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (final signal in signals()) {
      signal.disconnect(_rebuild);
    }
    super.dispose();
  }

    Slot _rebuild() {
    setState(onRebuild);
  }

  /// This callback will be passed to setState when this widget is rebuilt
  /// due to signal emission.
  void onRebuild() {}

  @override
  Widget build(BuildContext context);
}

