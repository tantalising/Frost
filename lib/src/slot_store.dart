import 'dart:collection';

/// This class wraps a hashSet to prevent direct access to it.
///
/// It only exposes the [SlotStore.add] and [SlotStore.remove] methods.
/// The add and remove methods keep a list of slots to be added or removed and
/// does not really add them to the set or remove them from the set until the
/// [SlotStore.sync] method is called. It facilitates mutating the set while
/// or other slots iterating over it. The intended use case is slots removing
/// or adding itself in a signal emission. Since the underlying set is hidden,
/// a readonly iterator of the set is provided by the [SlotStore.slots] method.
class SlotStore {
  final HashSet<Function> _slots = HashSet();

  final  _slotsToBeAdded = HashSet<Function>();
  final _slotsToBeRemoved = HashSet<Function>();

  void add(Function slot) {
    _slotsToBeAdded.add(slot);
  }

  void remove(Function slot) {
    _slotsToBeRemoved.add(slot);
  }

  Iterable<Function> slots() {
    return List<Function>.unmodifiable(_slots);
  }

  void sync() {
    _slots.addAll(_slotsToBeAdded);
    _slots.removeAll(_slotsToBeRemoved);
    _slotsToBeAdded.clear();
    _slotsToBeRemoved.clear();
  }
}