import 'dart:collection';

/// This class manages calling and storing slots.
class SlotStore {
  void add(Function slot) {
    _slotsToBeAdded.add(slot);
  }

  void addMultiSlot(List<Function> multiSlot) {
    _multiSlotsToBeAdded.add(multiSlot);
  }

  void remove(Function slot) {
    _slotsToBeRemoved.add(slot);
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot}) callSlots() {
    final ret = _callSlots(_slots.toList());
    final multiRet = _callMultiSlots();
    return ret.signatureMismatchedForSomeSlots ? ret : multiRet;
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot})
      callSlotsWithArgument<T>(T argument) {
    final ret = _callSlotsWithArgument(argument, _slots.toList());
    final multiRet = _callMultiSlotsWithArgument(argument);
    return ret.signatureMismatchedForSomeSlots ? ret : multiRet;
  }

  void sync() {
    _addSlotsPendingToBeAdded();
    _removeSlotsPendingToBeRemoved();
    _clearSetsOfPendingSlots();
  }

  // ----------------------------------------------------------------------- //

  void _addSlotsPendingToBeAdded() {
    _slots.addAll(_slotsToBeAdded);
    _multiSlots.addAll(_multiSlotsToBeAdded);
  }

  void _removeSlotsPendingToBeRemoved() {
    _slots.removeAll(_slotsToBeRemoved);
    // If a slot is in one of multi slots, then...
    for(final multiSlot in _multiSlots) {
      for (final slot in _slotsToBeRemoved) {
        if (multiSlot.contains(slot)) {
          multiSlot.remove(slot);
        }
      }
    }
  }

  void _clearSetsOfPendingSlots() {
    _slotsToBeAdded.clear();
    _slotsToBeRemoved.clear();
    _multiSlotsToBeAdded.clear();
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot}) _callSlots(
      List<Function> slots) {
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
      _callSlotsWithArgument<T>(T argument, List<Function> slots) {
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

  ({bool signatureMismatchedForSomeSlots, Function? slot}) _callMultiSlots() {
    for (final multiSlot in _multiSlots) {
      final ret = _callSlots(multiSlot);
      if (ret.signatureMismatchedForSomeSlots) {
        return ret;
      }
    }
    return _noMismatch;
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot})
      _callMultiSlotsWithArgument<T>(T argument) {
    for (final multiSlot in _multiSlots) {
      final ret = _callSlotsWithArgument(argument, multiSlot);
      if (ret.signatureMismatchedForSomeSlots) {
        return ret;
      }
    }
    return _noMismatch;
  }

  ({bool signatureMismatchedForSomeSlots, Function? slot}) _misMatched(
      Function slot) =>
      (signatureMismatchedForSomeSlots: true, slot: slot);

  // --------------------------------------------------------------- //

  final HashSet<Function> _slots = HashSet();

  final _slotsToBeAdded = HashSet<Function>();
  final _slotsToBeRemoved = HashSet<Function>();

  final _multiSlotsToBeAdded = HashSet<List<Function>>();

  final List<List<Function>> _multiSlots = [];

  static const _noMismatch =
  (signatureMismatchedForSomeSlots: false, slot: null);
}
