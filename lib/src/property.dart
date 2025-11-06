import 'package:frost/watcher.dart';
import 'package:frost/src/subscription_manager/subscription_manager.dart';

import 'signal.dart';

/// Class implementing property functionality.
/// A property is a combination of a value and a signal.
/// The property is useful when the model of the widget is too small.
/// In that case creating a property will be shorter.
/// Property contains a [Property.changed] signal which is emitted
/// automatically after setting [Property.value] or [Property.update].
/// It is best to use this in combination with [PropertyWidget].
class Property<T> {
  late T _value;
  /// This signal is emitted when the property is changed.
  /// Generally not intended to be used directly.
  /// If it is required to do something when the property changes,
  /// connect to this signal an appropriate slot.
  /// Don't forget to disconnect the slot when not needed anymore.

  /// See the [Watcher] for usage examples.
  final changed = Signal();

  Property(T value) {
    _value = value;
  }

  ///Returns the value of the property.
  T get value {
    return SubscriptionManager().connectToSubscribersOf(_value, changed);
  }

  ///Returns the value of the property.
  T call() {
    return value;
  }

  /// Sets the value of the property.
  set value(T newValue) {
    if (newValue == _value) return;
    _value = newValue;
    changed();
  }

  /// Updates value when it is a mutable object.
  void update(void Function(T value) updateFn) {
    updateFn(_value);
    changed();
  }
}

/// Creates a property by appending property after a value.
/// This is a shorter way for creating a property.
extension PropertyExtension<T extends Object> on T {
  Property<T> get property => Property<T>(this);
}