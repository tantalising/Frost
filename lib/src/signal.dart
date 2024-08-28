import 'slot_store.dart';
/// Signals help you to establish connections between two entities.
///
/// It is essentially a communication mechanism.
/// When an entity wants to notify others about something, it creates an
/// _signal_ and _emit_ it. It doesn't care about who wants to listen to the
/// signal. The interested parties will _connect_ to the signal instead.
/// They will _disconnect_ from the signal when there's no more need to listen
/// to it.
///
/// Let us create a class that will _emit_ signals for others to connect to.
/// ```dart
///  class SignalEmitter {
///     final somethingHappened = Signal();
///  }
/// ```
///
/// Let's create another class that is interested in listening to the signal
/// we just created.
/// ```dart
///class SignalReceiver {
///   Slot handleSomethingHappened() {
///     print("something happened.");
///   }
///   ```
///> Note:
///> _Slot_ is just a typedef for void.
///> It is used to highlight that the method is intended to be used as a slot.
///
/// Connect the slot to the signal to get notified about signal emission.
/// ```dart
///   signalEmitter.somethingHappened.connect(signalReceiver.handleSomethingHappened);
///   //connect(signalEmitter.somethingHappened, signalReceiver.handleSomethingHappened); <- or like this
///```
///
/// Now we will _emit_ the signal to notify others.
/// ```dart
/// signalEmitter.somethingHappened();
/// ```
/// Running the code would print "something happened."
///
/// Disconnect the slot from the signal when it is no more needed.
///
/// ```dart
///   signalEmitter.somethingHappened.disconnect(signalReceiver.handleSomethingHappened);
///   //disconnect(signalEmitter.somethingHappened, signalReceiver.handleSomethingHappened); <- or like this
///```


/// Helps visually distinguishing between slots and other methods.
/// Not necessary to use but helpful for void slots.
/// Slots must be a function with at most one argument.
typedef Slot = void;

/// The Signal class offering all the signal features.
class Signal {
  final _slotSet = SlotStore();

  /// in built connect function for object flavoured usage.
  void connect(Function slot) {
    _connect(this, slot);
  }

  /// in built disconnect function for object flavoured usage.
  void disconnect(Function slot) {
    _disconnect(this, slot);
  }

  /// Calls the slots connected with this signal.
  /// Optionally can pass an argument to the slot as well.
  /// If an argument is provided but the slot doesn't take one,
  /// then the argument is discarded and the slot is still called.
  void call<T>([T? argument]) {
    _slotSet.sync(); // See the SlotStore class docs for explanation
    _emit<T>(this, argument);
  }
}

const _connect = connect;
/// free floating connect function. Use it to connect a signal
/// to a slot.
void connect(Signal signal, Function slot) {
  signal._slotSet.add(slot);
}

const _disconnect = disconnect;
/// free floating disconnect function. Use to disconnect a signal
/// from a slot.
void disconnect(Signal signal, Function slot) {
  signal._slotSet.remove(slot);
}

/*----------------------- private -------------------------------*/

const _signalSlotMismatchErrorMessage =
    'flutter_signal: Slot must be a function'
    'with zero or one argument. Argument'
    'should be provided if expected by slot.';

// Just for a better looking assert.
// Function type doesn't provide much info regarding signature.
// Stricter types can't be used for some reason I don't remember.
const _signalSignature = true;
const _slotSignature = false;

void _emit<T>(Signal signal, [T? argument]) {
  if (argument == null) {
    _callSlots(signal);
  } else {
    _callSlotsWithArgument<T>(signal, argument);
  }
}

void _callSlots(Signal signal) {
  for (final slot in signal._slotSet.slots()) {
    try {
      slot();
    } on NoSuchMethodError {
      assert(_signalSignature == _slotSignature, _signalSlotMismatchErrorMessage);
    }
  }
}

void _callSlotsWithArgument<T>(Signal signal, T argument) {
  for (final slot in signal._slotSet.slots()) {
    try {
      slot(argument);
    } on NoSuchMethodError {
      try {
        slot(); // In case the user chose to ignore the argument. Signal passes an argument but this particular slot doesn't need it.
      } on NoSuchMethodError {
        assert(_signalSignature == _slotSignature, _signalSlotMismatchErrorMessage);
      }
    }
  }
}

