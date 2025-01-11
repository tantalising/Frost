import 'package:flutter/material.dart';
import 'package:flutter_signal/signal.dart';

/// A widget that automatically rebuilds whenever one of the signals
/// in [SignalStateFulWidget.signals] is emitted.
///
/// This is a convenience widget that should be used in place of a StatefulWidget when you have to connect and
/// disconnect some signals in a stateful widget's initState and dispose methods.

abstract class SignalStatefulWidget extends StatefulWidget {
  const SignalStatefulWidget({super.key, required Set<Signal> signals}): _signals = signals;

  final Set<Signal> _signals;

  @override
  SignalState createState();
}

abstract class SignalState<T extends SignalStatefulWidget> extends State<T> {
  @override
  void initState() {
    for (final signal in widget._signals) {
      signal.connect(_rebuild);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (final signal in widget._signals) {
      signal.disconnect(_rebuild);
    }
    super.dispose();
  }

    Slot _rebuild() {
    setState(onRebuild);
  }

  void onRebuild() {}

  @override
  void didUpdateWidget(covariant T oldWidget) {
    // Disconnect old signals and connect new ones if necessary.
    final oldSignals = oldWidget._signals;
    final currentSignals = widget._signals;

    final newSignals =
        currentSignals.where((signal) => !oldSignals.contains(signal));
    final notUsedSignals =
        oldSignals.where((signal) => !currentSignals.contains(signal));

    for (final signal in notUsedSignals) {
      signal.disconnect(_rebuild);
    }

    for (final signal in newSignals) {
      signal.connect(_rebuild);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context);
}

