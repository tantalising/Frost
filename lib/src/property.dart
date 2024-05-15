import 'signal.dart';

/// Class implementing property functionality.
/// A property is a combination of a value and a signal.
/// The property is useful when the model of the widget is too small.
/// In that case creating a property will be shorter.
/// Property contains a [Property.changed] signal which is emitted
/// automatically after calling [Property.set] or [Property.update].
/// It is best to use this in combination with [PropertyWidget].
class Property<T extends Object> {
  late T _value;
  final changed = Signal();
  Property(T value) {
    _value = value;
  }

  ///Returns the value of the property.
  T get value => _value;

  /// Sets the value of the property.
  set value(T newValue) {
    if (newValue == _value) return;
    changed(() => _value = newValue);
  }

  /// Updates value when it is a mutable object.
  void update(void Function(T value) updateFn) {
    changed(() => updateFn(_value));
  }
}

extension PropertyExtension<T extends Object> on T {
  Property<T> get property => Property<T>(this);
}
