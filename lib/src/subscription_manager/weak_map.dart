class WeakMap<K extends Object, V extends Object> {
  final Expando<V> _expando = Expando<V>();

  V? operator [](K key) => _expando[key];

  void operator []=(K key, V? value) {
    _expando[key] = value;
  }

  bool containsKey(K key) {
    return _expando[key] != null;
  }

  V? remove(K key) {
    final entry = _expando[key];
    _expando[key] = null;
    return entry;
  }
}