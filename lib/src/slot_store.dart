import 'dart:collection';

/// This class manages calling and storing slots.
class SlotStore {
  void add(Function slot) {
    _slotsToBeAdded.add(slot);
  }

  void remove(Function slot) {
    _slotsToBeRemoved.add(slot);
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot}) callSlots() {
    final ret = _callSlots(_slots);
    return ret;
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot})
      callSlotsWithArgument<T>(T argument) {
    final ret = _callSlotsWithArgument(argument, _slots);
    return ret;
  }

  void sync() {
    _addSlotsPendingToBeAdded();
    _removeSlotsPendingToBeRemoved();
    _clearSetsOfPendingSlots();
  }

  // ----------------------------------------------------------------------- //

  void _addSlotsPendingToBeAdded() {
    _slots.addAll(_slotsToBeAdded);
  }

  void _removeSlotsPendingToBeRemoved() {
    _slots.removeAll(_slotsToBeRemoved);
  }

  void _clearSetsOfPendingSlots() {
    _slotsToBeAdded.clear();
    _slotsToBeRemoved.clear();
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot}) _callSlots(
      Iterable<Function> slots) {
    for (final slot in slots) {
      try {
        slot();
      } on Error {
        return _misMatched(slot);
      }
    }
    return _noMismatch;
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot})
      _callSlotsWithArgument<T>(T argument, Iterable<Function> slots) {
    for (final slot in slots) {
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

  final _slotsToBeAdded = HashSet<Function>();
  final _slotsToBeRemoved = HashSet<Function>();

  static const _noMismatch =
  (signatureMismatchedForSomeSlots: false, slot: null);
}
