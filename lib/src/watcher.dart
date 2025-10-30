import 'package:flutter/material.dart';
import 'package:frost/src/property_widget_helpers/subscription_manager.dart';
import 'signal.dart';
import 'property.dart';

/// An Widget that accepts a watch that uses property and automatically rebuilds
/// when the property is changed.
///
/// Let us assume you need a property for a count. You can create the
/// property in the following way:
/// ```dart
/// final _count = 0.property; //private globals are fine.
/// final _count = Property<int>(0); // this works as well but ugly.
/// ```
/// Now to create a widget that shows this count and also updates
/// when the count changes, you can use the Watcher:
/// ```dart
///      Watcher(
///          watch: (context) => Text(
///          _count.value,
///          ),
///         ),
/// ```
/// Let us assume you have a class like this:
/// ```dart
///   class Count {
///     Count(this.count);
///     int count;
///   }
/// ```
///
///Create a property out of this class like this:
///```dart
/// final _count = Count(0).property;
///```
///You can update the property like this:
///```dart
/// _count.value = Count(1);
///```
///Though this works we don't want to create a new object here.
///This would have been fine if count was made of an int like this:
///```dart
/// final _count = 0.property;
/// //update like this;
/// _count.value = 2;
///```
///To change the interior of the value that is stored in the property
///use the [Property.update] method.
///```dart
/// _count.update((value) { value.count = 2 });
///```
/// If you just update the value directly, the Watcher
/// won't update the ui unless you emit the [Property.changed] signal as well.
///
/// If you want to connect  to some signals or properties manually then you
/// can use [Watcher.signal] or [Watcher.signals] and [Watcher.property] or
/// [Watcher.properties] arguments.
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

  /// A callback which does some work when the widget is created.
  final VoidCallback? onInit;

  /// A callback which does some work when the widget is disposed.
  final VoidCallback? onDispose;

  const Watcher(
      {super.key,
      this.property,
      this.properties,
      this.signal,
      this.signals,
      required this.watch,
      this.onInit,
      this.onDispose});
  @override
  State<Watcher> createState() => _WatcherState();
}

class _WatcherState extends State<Watcher> {
  @override
  void initState() {
    _connectProperties();
    _connectSignals();
    SubscriptionManager().subscribe(this, _rebuild);
    widget.onInit?.call();
    super.initState();
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
  Widget build(BuildContext context) {
    SubscriptionManager().startTracking(this);
    final widgetTree = widget.watch(context);
    SubscriptionManager().stopTracking(this);
    return widgetTree;
  }

  Slot _rebuild() {
    if (mounted) {
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
