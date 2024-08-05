import 'slot_store.dart';

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
    'signal: Slot must be a function'
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

