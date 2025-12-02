import 'package:flutter/material.dart';
import 'package:frost/src/subscription_manager/subscription_manager.dart';

import '../signal.dart';

/// Interface for models intended to be used with signal mechanism.
///
/// It is recommended to inherit from this class for easier usage of signals.
/// Use [Model.init] and [Model.dispose] to do some work when the model is added to [Store].
///  You can as well use the [Store] to store, update, access and remove your models.
///  In this case init and dispose
/// will be called automatically when [Store.add] and [Store.remove] is used.
/// See [Store] for more details.
abstract class Model {
  /// Does some work when the model is added to the [Store].
  void init() {}

  /// Cleans up when the model is removed from the [Store].
  void dispose() {}

  /// Returns the value and also connects the signal to any [Watcher]
  /// that accessed this value.
  @protected
  T getter<T extends Object>(T value, Signal signal) {
    return SubscriptionManager.connectToSubscribersOf(value, signal);
  }
}
