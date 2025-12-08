import 'package:flutter/foundation.dart';

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

  void callSlots<T>(T? argument) {
    final hasArgument = argument != null;
    final length = _slots.length;

    iterating = true;
    try {
      for (index = 0; index < length; index++) {
        final slot = _slots.elementAtOrNull(index);
        if (slot == null) break;

        if (hasArgument) {
          _callSlotWithArgument(slot, argument);
        } else {
          _callSlot(slot);
        }
      }
    } finally {
      iterating = false;
    }
  }

  void _callSlot<T>(Function slot) {
    try {
      slot();
      _adjustIndex();
    } on Error {
      if (kDebugMode) {
        final errorMessage = _errorMessage(slot, _slotCalledWithArgument);
        _slotCalledWithArgument = false;
        throw Exception(errorMessage);
      }
      return;
    }
  }

  void _callSlotWithArgument<T>(Function slot, T argument) {
    try {
      slot(argument);
      _adjustIndex();
    } on Error {
      // the whole point of this is not passing this as an argument. Because you will
      // have to pass that in non-debug modes as well when that data isn't even needed.
      _slotCalledWithArgument = true;
      _callSlot(slot);
    }
  }

  void _adjustIndex() {
    index -= indexCorrection;
    indexCorrection = 0;
  }

  // --------------------------------------------------------------- //

  final _slots = <Function>[];
  bool _slotCalledWithArgument = false;

  var indexCorrection = 0;
  var index = 0;
  bool iterating = false;
}

String _errorMessage<T>(Function slot, [T? argument]) {
  final calledWithArgument = argument != null;
  final argumentMessage = calledWithArgument
      ? 'with argument \'$argument\' of type \'${argument.runtimeType}\''
      : 'with no argument';

  String probablyArgumentMissingOrMismatched() {
    if (!calledWithArgument) {
      return '\n\tMost probable cause: An argument is expected by the slot but it was not provided with the signal.\n';
    }
    return '\n\tMost probable cause: Type of the argument provided with signal does not match with the type expected by the slot.\n';
  }

  String probablyMoreThanOneArgumentExpectedBySlot() {
    final moreThanOneArgExpected = slot.toString().contains(',');
    return moreThanOneArgExpected
        ? '\n\tMost probable cause: Slot takes more than one argument which is not supported.\n'
        : '';
  }

  String helpfulMessage() {
    final message = probablyMoreThanOneArgumentExpectedBySlot();
    return message == '' ? probablyArgumentMissingOrMismatched() : message;
  }

  String slotMessages(bool calledWithArgument) {
    return calledWithArgument
        ? 'Slot takes more than one argument.'
        : 'Slot expects argument but was not provided.';
  }

  final slotMessage = slotMessages(calledWithArgument);
  final message = '\n\nfrost: Signal was emitted $argumentMessage.\n'
      'Slot \'$slot\' which was connected to this signal could not be called.\n'
      'One of the following cases may have occurred: \n\n'
      '\t1. Expected argument type does not match with the provided one.\n'
      '\t2. $slotMessage\n'
      '\t ${helpfulMessage()}'
      '\nNote that Slot must be a function '
      'with zero or one argument.\n'
      'fix the issue to continue without assertion failure.'
      '\n';
  return message;
}
