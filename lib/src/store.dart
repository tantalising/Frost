import 'package:flutter/material.dart';
import 'model.dart';

/// Utility class for storing models of your app.
///
/// Models must be of type [Model].
/// The init method of [Model] is called automatically when a model
/// is added to this store.
/// Similarly dispose method of [Model] is called when a model is
/// removed from the store.
/// You cannot add two instances of same model in the store. It will not
/// update the underlying model even if you add twice.
/// You can replace an instance of a model with another one using the
/// [Store.replace] method.
///
/// Note that it is not necessary to use this class. If you aren't making your
/// models from inheriting [Model] then
/// use your favourite way of dependency injection.

// The class ModelStore is lazy and does not really add any model
// until that particular model is requested. It helps in cases
// where user wants to initialize models in bulk and use them
// later or may not even use them. In this way it potentially saves resources.
typedef ModelBuilder<T extends Model> = T Function();

/// Stores and manages models of the app.
abstract class Store {
  /// Adds a model to the Store.
  /// No model is added if a model of same type already exists.
  /// Model is added lazily unless [lazy] is false that is no model is created until it is
  /// accessed for the first time.
  /// To add a model when another one of same type already exists, provide
  /// a unique string id using the optional [id] parameter.
  static void add<T extends Model>(ModelBuilder<T> modelBuilder,
      {String? id, bool lazy = true}) {
    final key = id ?? T;
    if (lazy) {
      _LazyModelStore.add(modelBuilder, key);
    } else {
      _EagerModelStore.add(modelBuilder(), key);
    }
  }

  /// Removes the model of given type from the store and returns it.
  /// It also calls the dispose method of the model.
  /// Returns null if no model is found.
  /// Use the [id] parameter to remove an instance of id model.
  /// See [Store.add] for details.
  static T? remove<T extends Model>([String? id]) {
    final key = id ?? T;
    _LazyModelStore.remove(key);
    return _EagerModelStore.remove(key);
  }

  /// Returns the model of given type from the store.
  /// Returns null if no such model exists.
  /// Use the [id] parameter to get an instance of id model.
  /// See [Store.add] for details.
  static T? get<T extends Model>([String? id]) {
    final key = id ?? T;
    return _EagerModelStore.get(key) ?? _LazyModelStore.get(key);
  }

  /// Replaces an existing model from the store with the same type of the given
  /// model.
  ///
  /// Note that [Store.add] doesn't replace a model if it already exists.
  /// Instead it silently ignores the request. So use this method for replacing
  /// an entire model.
  /// Use the [id] parameter to replace an instance of id model.
  /// See [Store.add] for details.
  static void replace<T extends Model>(ModelBuilder<T> builder, [String? id]) {
    final key = id ?? T;
    _LazyModelStore.replace(builder, key);
    _EagerModelStore.replace(builder(), key);
  }

  /// Removes all the models from the store.
  static void clear() {
    _LazyModelStore.clear();
    _EagerModelStore.clear();
  }
}

abstract class _LazyModelStore {
  static final _modelBuilderRepository =
      _TwoKeyTypeMap<Type, String, ModelBuilder>();

  static void add<T extends Model>(ModelBuilder<T> modelBuilder, Object key) {
    _modelBuilderRepository[key] = modelBuilder;
  }

  static void remove(Object key) {
    _modelBuilderRepository.remove(key);
  }

  static T? get<T extends Model>(Object key) {
    return _buildModelFromBuilder(key);
  }

  static T? _buildModelFromBuilder<T extends Model>(Object key) {
    final model = _modelBuilderRepository[key]?.call() as T?;
    if (model != null) _EagerModelStore.add(model, key);
    return model;
  }

  static void replace<T extends Model>(ModelBuilder<T> builder, Object key) {
    _modelBuilderRepository.remove(key);
    _modelBuilderRepository[key] = builder;
  }

  /// Removes all the models from the store.
  static void clear() {
    _modelBuilderRepository.clear();
  }
}

abstract class _EagerModelStore {
  static final _modelRepository = _TwoKeyTypeMap<Type, String, Model>();

  static void add<T extends Model>(T model, Object key) {
    if (_modelRepository.containsKey(key)) return;
    model.init();
    _modelRepository[key] = model;
  }

  static T? remove<T extends Model>(Object key) {
    final T? model = _modelRepository.remove(key) as T?;
    model?.dispose();
    return model;
  }

  static T? get<T extends Model>(Object key) {
    final T? model = _modelRepository[key] as T?;
    return model;
  }

  static void replace<T extends Model>(T model, Object key) {
    remove(key);
    add(model, key);
  }

  static void clear() {
    _modelRepository.clear();
  }
}

class _TwoKeyTypeMap<S extends Object, T extends Object, V extends Object> {
  final firstTypeMap = <S, V>{};
  final secondTypeMap = <T, V>{};

  void operator []=(Object key, V value) {
    if (_keyTypeNeitherSorT(key)) {
      return;
    } // we could've avoided this, had dart union types
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

  bool _keyTypeNeitherSorT<K extends Object>(K key) {
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
  static Map<Type, Model> get modelRepository =>
      _EagerModelStore._modelRepository.firstTypeMap;

  static Map<String, Model> get idModelRepository =>
      _EagerModelStore._modelRepository.secondTypeMap;

  static Map<Type, ModelBuilder> get modelBuilderRepository =>
      _LazyModelStore._modelBuilderRepository.firstTypeMap;

  static Map<String, ModelBuilder> get idModelBuilderRepository =>
      _LazyModelStore._modelBuilderRepository.secondTypeMap;
}
