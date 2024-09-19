import 'signal.dart';

/// Class implementing property functionality.
/// A property is a combination of a value and a signal.
/// The property is useful when the model of the widget is too small.
/// In that case creating a property will be shorter.
/// Property contains a [Property.changed] signal which is emitted
/// automatically after setting [Property.value] or [Property.update].
/// It is best to use this in combination with [PropertyWidget].
class Property<T extends Object> {
  late T _value;
  /// This signal is emitted when the property is changed.
  /// Generally not intended to be used directly.
  /// If it is required to do something when the property changes,
  /// connect to this signal an appropriate slot.
  /// Don't forget to disconnect the slot when not needed anymore.

  /// See the [PropertyWidget] for usage examples.
  final changed = Signal(); // this signal adapts the undocumented privateChanged
  // in a way such that no argument is needed to be provided by the user. The
  // undocumented signal insists on an argument which works as the callback of the
  // setState. This can't be private since PropertyWidget needs this signal.
  // part/part of can't be used for library export files and I don't like these
  // two classes to be together. Maybe we need friends in dart?
  final privateChanged = Signal();

  Property(T value) {
    _value = value;

    // Emit one of privateChanged or changed whenever the other one is emitted.
    connect(privateChanged, _changedEmitter);
    connect(changed, _privateChangedEmitter);
  }

  Slot _changedEmitter(_) {
    disconnect(changed, _privateChangedEmitter);
    changed();
    connect(changed, _privateChangedEmitter);
  }

  Slot _privateChangedEmitter() {
    disconnect(privateChanged, _changedEmitter);
    privateChanged(()=>());
    connect(privateChanged, _changedEmitter);
  }

  ///Returns the value of the property.
  T get value => _value;

  /// Sets the value of the property.
  set value(T newValue) {
    if (newValue == _value) return;
    privateChanged(() => _value = newValue);
  }

  /// Updates value when it is a mutable object.
  void update(void Function(T value) updateFn) {
    privateChanged(() => updateFn(_value));
  }
}

/// Creates a property by appending property after a value.
/// This is a shorter way for creating a property.
extension PropertyExtension<T extends Object> on T {
  Property<T> get property => Property<T>(this);
}
