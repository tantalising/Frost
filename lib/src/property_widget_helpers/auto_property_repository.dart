import '../../property.dart';

class AutoPropertyRepository {
  final _properties = <Property>{};
  final Function rebuild;

  AutoPropertyRepository(this.rebuild);

  void add<T extends Object>(Property<T> property) {
    if (_properties.contains(property)) return;
    property.changed.connect(rebuild);
    _properties.add(property);
  }

  void clear() {
    for (final property in _properties) {
      property.changed.disconnect(rebuild);
    }
    _properties.clear();
  }
}

