import 'package:flutter/material.dart';
import 'property.dart';

/// An Widget that accepts an property and automatically rebuilds
/// when the property is changed via [Property.set] or [Property.update]
/// function or the [Property.changed] signal is emitted by user.
/// The type is used to verify that the property supplied indeed is
/// the right one. Since multiple properties can have different types,
/// there's no need to specify type in that case.
class PropertyWidget<T extends Object> extends StatefulWidget {
  /// The builder for the widget that uses the property.
  final Widget Function() builder;

  /// The property that the builder uses.
  final Property<T>? property;

  /// Field for connecting to multiple properties.
  final Set<Property>? properties;

  const PropertyWidget(
      {super.key, this.property, this.properties, required this.builder});
  @override
  State<PropertyWidget> createState() => _PropertyWidgetState();
}

class _PropertyWidgetState extends State<PropertyWidget> {
  @override
  void initState() {
    widget.property?.changed.connect(setState);
    widget.properties?.forEach((property) {
      property.changed.connect(setState);
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.property?.changed.disconnect(setState);
    widget.properties?.forEach((property) {
      property.changed.disconnect(setState);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }
}