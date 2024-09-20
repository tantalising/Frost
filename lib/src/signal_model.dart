import 'package:flutter/material.dart';

/// Interface for models intended to be used with signal mechanism.
///
/// It is recommended to implement or inherit from this class for easier usage of signals.
/// The [SignalModel.init] and [SignalModel.dispose] must be called manually by the user at appropriate
/// times, if it is not being used with a [SignalWidget]. You can as well use the
/// [ModelStore] to store, update, access and remove your models. In this case init and dispose
/// will be called automatically when [ModelStore.add] and [ModelStore.remove] is used.
/// See [ModelStore] for more details.
abstract class SignalModel {
  SignalModel();

  /// Does some work when the model is added to the [ModelStore].
  void init() {}

  /// Cleans up when the model is removed from the [ModelStore].
  void dispose() {}
}

/// Utility class for storing models of your app.
///
/// Models must be of type [SignalModel].
/// The init method of [SignalModel] is called automatically when a model
/// is added to this store.
/// Similarly dispose method of [SignalModel] is called when a model is
/// removed from the store.
/// You cannot add two instances of same model in the store. It will not
/// update the underlying model even if you add twice.
/// You can replace an instance of a model with another one using the
/// [ModelStore.replace] method.
///
/// Note that it is not necessary to use this class. If you aren't making your
/// models from [SignalModel] then don't provide a model to [SignalWidget] and
/// use your favourite way of dependency injection.

// The class ModelStore is lazy and does not really add any model
// until that particular model is requested. It helps in cases
// where user wants to initialize models in bulk and use them
// later or may not even use them. In this way it potentially saves resources.
typedef ModelBuilder<T extends SignalModel> = T Function();

/// Stores and manages models of the app.
abstract class ModelStore {
  static final _modelBuilderRepository = _TwoKeyTypeMap<Type, String, ModelBuilder>();

  /// Adds a model to the Store.
  /// No model is added if a model of same type already exists.
  /// Model is added lazily that is no model is created until it is
  /// accessed for the first time.
  /// To add a model when another one of same type already exists, provide
  /// a unique string id using the optional [id] parameter.
  static void add<T extends SignalModel>(ModelBuilder<T> modelBuilder, [String? id]) {
     final key = id ?? T;
    _modelBuilderRepository[key] = modelBuilder;
  }

  /// Adds the model to the store immediately instead of lazily like [ModelStore.add]
  /// Provide a unique string id to the optional [id] parameter to add more than one
  /// instance of same model.
  static void addEager<T extends SignalModel>(T model, [String? id]) {
    final key = id ?? T;
    _EagerModelStore.add<T>(model, key);
  }

  /// Removes the model of given type from the store and returns it.
  /// It also calls the dispose method of the model.
  /// Returns null if no model is found.
  /// Use the [id] parameter to remove an instance of id model.
  /// See [ModelStore.add] for details.
  static T? remove<T extends SignalModel>([String? id]) {
    final key = id ?? T;
    _modelBuilderRepository.remove(key);
    return _EagerModelStore.remove<T>(key);
  }

  /// Returns the model of given type from the store.
  /// Returns null if no such model exists.
  /// Use the [id] parameter to get an instance of id model.
  /// See [ModelStore.add] for details.
  static T? get<T extends SignalModel>([String? id]) {
    final key = id ?? T;
    return _EagerModelStore.get(key) ?? _buildModelFromBuilder(key);
  }

  static T? _buildModelFromBuilder<T extends SignalModel>(Object key) {
    final model = _modelBuilderRepository[key]?.call() as T?;
    switch (model) {
      case null:
        return model;
      case _:
        _EagerModelStore.add<T>(model, key);
        return model;
    }
  }

  /// Replaces an existing model from the store with the same type of the given
  /// model.
  ///
  /// Note that [ModelStore.add] doesn't replace a model if it already exists.
  /// Instead it silently ignores the request. So use this method for replacing
  /// an entire model.
  /// Use the [id] parameter to replace an instance of id model.
  /// See [ModelStore.add] for details.
  static void replace<T extends SignalModel>(ModelBuilder<T> builder, [String? id]) {
    final key = id ?? T;
    _modelBuilderRepository.remove(key);
    _modelBuilderRepository[key] = builder;
    _EagerModelStore.replace(builder(), key);
  }

  /// Removes all the models from the store.
  static void clear() {
    _modelBuilderRepository.clear();
    _EagerModelStore.clear();
  }
}

abstract class _EagerModelStore {
  static final _modelRepository = _TwoKeyTypeMap<Type, String, SignalModel>();

  static void add<T extends SignalModel>(T model, Object key) {
    if (_modelRepository.containsKey(key)) return;
    model.init();
    _modelRepository[key] = model;
  }

  static T? remove<T extends SignalModel>(Object key) {
    final T? model = _modelRepository.remove(key) as T?;
    model?.dispose();
    return model;
  }

  static T? get<T extends SignalModel>(Object key) {
    final T? model = _modelRepository[key] as T?;
    return model;
  }

  static void replace<T extends SignalModel>(T model, Object key) {
    remove(key);
    add(model, key);
  }

  static void clear() {
    _modelRepository.clear();
  }
}

class _TwoKeyTypeMap<S extends Object, T extends Object, V extends Object> {
  final firstTypeMap = <S,V>{};
  final secondTypeMap = <T,V>{};

  void operator []=(Object key, V value) {
    if (_keyTypeNeitherSorT(key)) return; // we could've avoided this, had dart union types
    _targetMap(key)[key] = value;
}

  V? operator [](Object key) {
    if (_keyTypeNeitherSorT(key)) return null;
    return _targetMap(key)[key];
  }

  V? remove<X extends Object>(X key) {
    if (_keyTypeNeitherSorT(key)) return null;
    return _targetMap(key).remove(key);
  }

  bool containsKey<X extends Object>(X key) {
    return _targetMap(key).containsKey(key);
  }

  void clear() {
    firstTypeMap.clear();
    secondTypeMap.clear();
  }

  bool _keyTypeNeitherSorT<Key extends Object>(Key key) {
    final bounded = key is S || key is T;
    return !bounded;
  }

  Map<Object, V> _targetMap<X extends Object>(X key) {
    final targetMap = key is S ? firstTypeMap : secondTypeMap;
    return targetMap;
  }
}

@visibleForTesting
abstract class TestStub {
  static Map<Type, SignalModel> get modelRepository =>
      _EagerModelStore._modelRepository.firstTypeMap;
  static Map<Type, ModelBuilder> get modelBuilderRepository =>
      ModelStore._modelBuilderRepository.firstTypeMap;
}
