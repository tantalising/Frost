/// Interface for models intended to be used with signal mechanism.
///
/// It is recommended to implement or inherit from this class for easier usage of signals.
/// The init and dispose must be called manually by the user at the appropriate
/// times. See [ModelStore] for an easy way of using these methods.
abstract class SignalModel {
  /// Does some work when the model is added to the [ModelStore].
  void init() {}
  /// Cleans up when the model is removed from the [ModelStore].
  void dispose() {}
}

/// Utility class for storing models of your app.
///
/// It is not necessary to use this class. It is provided as a convenience.
/// Models must be of type [SignalModel].
/// The init method of [SignalModel] is called automatically when a model
/// is added to this store.
/// Similarly dispose method of [SignalModel] is called when a model is
/// removed from the store.
///
/// You cannot add two instances of same model in the store.
/// There's other dedicated packages for this purpose with more features.
/// This is intended to be a simple solution for basic usage.
/// Feel free to use other packages which are appropriate for your needs.
abstract class ModelStore {
  static final _modelRepository = <Type, SignalModel>{};

  /// Adds a model to the Store.
  /// No model is added if a model of same type already exists.
  static void add<T extends SignalModel>(T model) {
    if (_modelRepository.containsKey(T)) return;
    model.init();
    _modelRepository[T] = model;
  }

  /// Removes the model of given type from the store and returns it.
  /// It also calls the dispose method of the model.
  /// Returns null if no model is found.
  static T? remove<T extends SignalModel>() {
   final T? model = _modelRepository.remove(T) as T?;
   model?.dispose();
   return model;
  }

  /// Returns the model of given type from the store.
  /// Returns null if no such model exists.
  static T? get<T extends SignalModel>() {
    final T? model = _modelRepository[T] as T?;
    return model;
  }

  /// Replaces an existing model from the store with the same type of the given
  /// model.
  ///
  /// Note that [ModelStore.add] doesn't replace a model if it already exists.
  /// Instead it silently ignores the request. So use this method for replacing
  /// an entire model.
  static void replace<T extends SignalModel>(T model) {
    remove<T>();
    add<T>(model);
  }

  /// Removes all the models from the store.
  static void clear() {
    _modelRepository.clear();
  }
}
