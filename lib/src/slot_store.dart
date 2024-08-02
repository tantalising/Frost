import 'dart:collection';

class SlotStore {
  final HashSet<Function> _slots = HashSet();
  add(Function slot) {
    return _slots.add(slot);
  }
  remove(Function slot) {
    return _slots.remove(slot);
  }
  Iterable<Function> slots() {
    return List<Function>.unmodifiable(_slots);
  }
}