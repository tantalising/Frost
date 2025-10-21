import 'auto_property_repository.dart';
import '../../property_widget.dart';
import 'weak_map.dart';

// read the definitions carefully to understand this class better.
// auto property: a property to which rebuild methods of subscribers should be
//                automatically connected whenever that property is read.

// auto property repository: where auto properties of subscribers are held.
//               whenever a property is added to repository, the repository
//               owner's rebuild method is connected to this property.

// auto property subscriber: a property widget that wants its rebuild method to
//               be connected to any property(which are now its auto properties)
//               that is being read by anything.

// property widgets should call subscribe() to be a subscriber and unsubscribe()
// when no more properties should be connected to its rebuild method.

class AutoPropertyManager {
  static final AutoPropertyManager _instance =
      AutoPropertyManager._internal();
  final _repositories = WeakMap<PropertyWidget, AutoPropertyRepository>();
  final _subscribers = <PropertyWidget>{};

  AutoPropertyManager._internal();
  factory AutoPropertyManager() {
    return _instance;
  }

  void openRepo(PropertyWidget subscriber, Function rebuild) {
    if (_repositories.containsKey(subscriber)) return;
    _repositories[subscriber] = AutoPropertyRepository(rebuild);
  }

  void subscribe(PropertyWidget widget) {
    if (_subscribers.contains(widget)) return;
    _subscribers.add(widget);
  }

  void unsubscribe(PropertyWidget widget) {
    if (_subscribers.contains(widget)) return;
    _subscribers.remove(widget);
  }

  Set<PropertyWidget> subscribers() {
    return Set.unmodifiable(_subscribers);
  }

  AutoPropertyRepository? getRepo(PropertyWidget widget) {
    return _repositories[widget];
  }

  void closeRepo(PropertyWidget subscriber) {
    if (_repositories.containsKey(subscriber)) return;
    final repo = _repositories.remove(subscriber);
    repo?.clear();
  }
}
