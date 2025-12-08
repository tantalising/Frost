typedef ReturnType = ({bool signatureMismatchedForSomeSlots, Function? slot});

/// This class manages calling and storing slots.
class SlotStore {
  void add(Function slot) {
    if (_slots.contains(slot)) return;
    _slots.add(slot);
  }

  void remove(Function slot) {
    if (iterating) {
      var slotIndex = _slots.indexOf(slot);

      final slotRemoved = slotIndex >= 0;
      final wasSituatedBeforeCurrentIndex = slotIndex <= index;
      if (slotRemoved && wasSituatedBeforeCurrentIndex) {
        indexCorrection += 1;
      }
    }
    _slots.remove(slot);
  }

  ReturnType callSlots() {
    ReturnType returnValue = _noMismatch;
    final length = _slots.length;
    iterating = true;

    for (index = 0; index < length; index++) {
      final slot = _slots.elementAtOrNull(index);
      if (slot == null) break;
      try {
        slot();
       _adjustIndex();
      } on Error {
        returnValue = _misMatched(slot);
        break;
      }
    }

    index = 0;
    iterating = false;
    return returnValue;
  }

  ReturnType callSlotsWithArgument<T>(T argument) {
    ReturnType returnValue = _noMismatch;
    var length = _slots.length;
    iterating = true;
    for (index = 0; index < length; index++) {
      final slot = _slots.elementAtOrNull(index);
      if (slot == null) break;
      try {
        slot(argument);
        _adjustIndex();
      } on Error {
        try {
          slot(); // In case the user chose to ignore the argument. Signal passes an argument but this particular slot doesn't need it.
          _adjustIndex();
        } on NoSuchMethodError {
          returnValue = (signatureMismatchedForSomeSlots: false, slot: slot);
          break;
        }
      }
    }
    index = 0;
    iterating = false;
    return returnValue;
  }

   void _adjustIndex() {
     index -= indexCorrection;
     indexCorrection = 0;
  }

  ReturnType _misMatched(Function slot) =>
      (signatureMismatchedForSomeSlots: true, slot: slot);

  // --------------------------------------------------------------- //

  final _slots = <Function>[];

  var indexCorrection = 0;
  var index = 0;
  bool iterating = false;

  static const _noMismatch =
      (signatureMismatchedForSomeSlots: false, slot: null);
}
