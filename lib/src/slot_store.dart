import 'dart:collection';

/// This class manages calling and storing slots.
class SlotStore {
  void add(Function slot) {
    _slots.add(slot);
  }

  void remove(Function slot) {
    _slots.remove(slot);
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot}) callSlots() {
    for (final slot in _slots) {
      try {
        slot();
      } on Error {
        return _misMatched(slot);
      }
    }
    return _noMismatch;
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot})
      callSlotsWithArgument<T>(T argument) {
    for (final slot in List.of(_slots, growable: false)) {
      try {
        slot(argument);
      } on Error {
        try {
          slot(); // In case the user chose to ignore the argument. Signal passes an argument but this particular slot doesn't need it.
        } on NoSuchMethodError {
          return (signatureMismatchedForSomeSlots: false, slot: slot);
        }
      }
    }
    return _noMismatch;
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot}) _misMatched(
      Function slot) =>
      (signatureMismatchedForSomeSlots: true, slot: slot);

  // --------------------------------------------------------------- //

  final LinkedHashSet<Function> _slots = LinkedHashSet();

  static const _noMismatch =
  (signatureMismatchedForSomeSlots: false, slot: null);
}
