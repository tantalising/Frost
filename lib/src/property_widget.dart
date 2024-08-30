import 'package:flutter/material.dart';
import 'property.dart';

/// An Widget that accepts a property and automatically rebuilds
/// when the property is changed by setting [Property.value] or
/// calling [Property.update] method or the [Property.changed]
/// signal is emitted by the user.
///
/// The type is used to verify that the property supplied indeed is
/// the right one. Since multiple properties can have different types,
/// there's no need to specify type in that case.
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
///          property: _count,
///          builder: () => Text(
///          _count.value.toString(),
///          style: Theme.of(context).textTheme.headlineMedium,
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
class PropertyWidget<T extends Object> extends StatefulWidget {
  /// The builder for the widget that uses the property.
  final Widget Function() builder;

  /// The property that the builder uses. Use when connecting only one property.
  final Property<T>? property;

  /// Field for connecting to multiple properties.
  final Set<Property>? properties;

  /// A callback which does some work when the widget is created.
  final VoidCallback? onInit;

  /// A callback which does some work when the widget is disposed.
  final VoidCallback? onDispose;

  const PropertyWidget(
      {super.key, this.property, this.properties, required this.builder, this.onInit, this.onDispose});
  @override
  State<PropertyWidget> createState() => _PropertyWidgetState();
}

class _PropertyWidgetState extends State<PropertyWidget> {
  @override
  void initState() {
    assert(widget.property != null || widget.properties != null,
    'PropertyWidget: Provide value for at least one of property or properties parameter');
    widget.property?.changed.connect(setState);
    widget.properties?.forEach((property) {
      property.changed.connect(setState);
    });
    widget.onInit?.call();
    super.initState();
  }

  @override
  void dispose() {
    widget.property?.changed.disconnect(setState);
    widget.properties?.forEach((property) {
      property.changed.disconnect(setState);
    });
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }
}