import 'package:flutter/material.dart';
import 'package:frost/src/subscription_manager/subscription_manager.dart';
import 'signal.dart';
import 'property.dart';

/// A Widget that automatically tracks [Property] access and rebuilds when they change.
///
/// The [Watcher] is the primary way to consume state in Frost. It uses a smart
/// tracking system that detects which properties are accessed within the [watch]
/// builder and subscribes to them.
///
/// ### Basic Usage
/// ```dart
/// final count = 0.property;
///
/// Watcher(
///   watch: (context) => Text("Count: ${count.value}"),
/// )
/// ```
///
/// ### Lifecycle & Manual Signals
/// [Watcher] can replace [StatefulWidget] for simple lifecycle needs or explicit signal listening.
///
/// ```dart
/// Watcher(
///   onInit: acquireSomeController,
///   onDispose: releaseController,
///   signal: myCustomSignal, // Rebuilds when this signal emits
///   signals: {signal1, signal2} // More than one signal can be connected if needed.
///   watch: (context) => const Text("Signal(s) emitted! Using some controller as well."),
/// )
/// ```
class Watcher extends StatefulWidget {
  /// The builder for the widget that uses property inside itself.
  final Widget Function(BuildContext context) watch;

  /// Optional property that when changed rebuilds the widget. Use when connecting only one property.
  final Property? property;

  /// Optional Field for connecting to multiple properties.
  final Set<Property>? properties;

  /// Optional signal that when emitted rebuilds the widget. Use when connecting only one signal.
  final Signal? signal;

  /// Optional Field for connecting to multiple signals.
  final Set<Signal>? signals;

  /// Optional function that makes the watcher rebuild only when it returns true
  final bool Function()? when;

  /// A callback which is called when this widget is reinserted into the tree after having been
  /// removed via deactivate method of the state object of this widget.
  final VoidCallback? onActivate;

  /// A callback which is called when the deactivate method of this widget's state is called.
  final VoidCallback? onDeactivate;

  /// A callback which does some work when the widget is created.
  final VoidCallback? onInit;

  /// A callback which does some work when the widget is disposed.
  final VoidCallback? onDispose;

  const Watcher({
    super.key,
    this.property,
    this.properties,
    this.signal,
    this.signals,
    required this.watch,
    this.when,
    this.onActivate,
    this.onDeactivate,
    this.onInit,
    this.onDispose,
  });
  @override
  State<Watcher> createState() => _WatcherState();
}

class _WatcherState extends State<Watcher> {
  @override
  void initState() {
    super.initState();
    _connectProperties();
    _connectSignals();
    SubscriptionManager().subscribe(this, _rebuild);
    widget.onInit?.call();
  }

  @override
  void dispose() {
    _disconnectProperties();
    _disconnectSignals();
    SubscriptionManager().unsubscribe(this);
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  void deactivate() {
    widget.onDeactivate?.call();
    super.deactivate();
  }

  @override
  void activate() {
    widget.onActivate?.call();
    super.activate();
  }

  @override
  Widget build(BuildContext context) {
    SubscriptionManager().startTracking(this);
    final widgetTree = widget.watch(context);
    SubscriptionManager().stopTracking(this);
    return widgetTree;
  }

  Slot _rebuild() {
    final shouldRebuild = widget.when?.call() ?? true;
    if (mounted && shouldRebuild) {
      setState(() => ());
    }
  }

  void _connectProperties() {
    for (final property in _properties()) {
      property.changed.connect(_rebuild);
    }
  }

  void _disconnectProperties() {
    for (final property in _properties()) {
      property.changed.disconnect(_rebuild);
    }
  }

  void _connectSignals() {
    for (final signal in _signals()) {
      signal.connect(_rebuild);
    }
  }

  void _disconnectSignals() {
    for (final signal in _signals()) {
      signal.disconnect(_rebuild);
    }
  }

  Set<Property> _properties() {
    final properties = widget.properties ?? {};
    if (widget.property != null) {
      properties.add(widget.property!);
    }
    return properties;
  }

  Set<Signal> _signals() {
    final signals = widget.signals ?? {};
    if (widget.signal != null) {
      signals.add(widget.signal!);
    }
    return signals;
  }
}
