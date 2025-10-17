import 'package:flutter/material.dart';
import 'package:frost/src/property_widget_helpers/auto_property_manager.dart';
import 'signal.dart';
import 'property.dart';

/// An Widget that accepts a builder that uses property and automatically rebuilds
/// when the property is changed by setting [Property.value] or
/// calling [Property.update] method or the [Property.changed]
/// signal is emitted by the user.
///
/// Let us assume you need a property for a count. You can create the
/// property in the following way:
/// ```dart
/// final _count = 0.property; //private globals are fine.
/// final _count = Property<int>(0); // this works as well but ugly.
/// ```
/// Now to create a widget that shows this count and also updates
/// when the count changes, you can use the PropertyWidget:
/// ```dart
///      PropertyWidget(
///          builder: (context) => Text(
///          _count.value.toString(),
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
/// If you just update the value directly, the property widget
/// won't update the ui unless you emit the [Property.changed] signal as well.
class PropertyWidget extends StatefulWidget {
  /// The builder for the widget that uses property inside itself.
  final Widget Function(BuildContext context) builder;

  /// Optional property that when changed rebuilds the widget. Use when connecting only one property.
  final Property? property;

  /// Field for connecting to multiple properties.
  final Set<Property>? properties;

  /// A callback which does some work when the widget is created.
  final VoidCallback? onInit;

  /// A callback which does some work when the widget is disposed.
  final VoidCallback? onDispose;

  const PropertyWidget(
      {super.key,
      this.property,
      this.properties,
      required this.builder,
      this.onInit,
      this.onDispose});
  @override
  State<PropertyWidget> createState() => _PropertyWidgetState();
}

class _PropertyWidgetState extends State<PropertyWidget> {
  @override
  void initState() {
    for (final property in properties()) {
      property.changed.connect(rebuild);
    }
    AutoPropertyManager().openRepo(widget, rebuild);
    widget.onInit?.call();
    super.initState();
  }

  @override
  void dispose() {
    for (final property in properties()) {
      property.changed.connect(rebuild);
    }
    AutoPropertyManager().closeRepo(widget);
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AutoPropertyManager().subscribe(widget);
    final widgetTree = widget.builder(context);
    AutoPropertyManager().unsubscribe(widget);
    return widgetTree;
  }

  Slot rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  Set<Property> properties() {
    final properties = widget.properties ?? {};
    if (widget.property != null) {
      properties.add(widget.property!);
    }
    return properties;
  }
}
