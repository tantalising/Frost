import 'package:flutter/material.dart';
import 'signal.dart';
import 'signal_model.dart';

class SignalWidget<T extends SignalModel> extends StatefulWidget {
  final Widget Function() builder;
  final Set<Signal>? signals;
  final Signal? signal;
  final T? model;
  final VoidCallback? onInit;
  final VoidCallback? onDispose;

  SignalWidget({
    super.key,
    this.signals,
    required this.builder,
    this.signal,
    this.model,
    this.onInit,
    this.onDispose,
  }) {
    if (model != null) {
      ModelStore.add<T>(model!);
    }
  }

  void _removeThisModel() {
    ModelStore.remove<T>();
  }


  @override
  State<StatefulWidget> createState() => _SignalWidgetState();
}

class _SignalWidgetState extends State<SignalWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }

  @override
  void initState() {
    widget.signal?.connect(_rebuild);
    final signals = widget.signals ?? {};
    for (final signal in signals) {
      connect(signal, _rebuild);
    }
    widget.onInit?.call();
    super.initState();
  }

  @override
  void dispose() {
    widget.signal?.disconnect(_rebuild);
    final signals = widget.signals ?? {};
    for (final signal in signals) {
      signal.disconnect(_rebuild);
    }
    widget.onDispose?.call();
    if (widget.model != null) {
      widget._removeThisModel();
    }
    super.dispose();
  }

  Slot _rebuild() {
    setState(() {});
  }
}
