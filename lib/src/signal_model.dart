/// Interface for models intended to be used with signal mechanism.
///
/// It is recommended to implement or inherit from this class for easier usage of signals.
/// The [SignalModel.init] and [SignalModel.dispose] must be called manually by the user at appropriate
/// times, if it is not being used with a [SignalWidget]. You can as well use the
/// [ModelStore] to store, update, access and remove your models. In this case init and dispose
/// will be called automatically when [ModelStore.openRepo] and [ModelStore.closeRepo] is used.
/// See [ModelStore] for more details.
abstract class SignalModel {
  SignalModel();

  /// Does some work when the model is added to the [ModelStore].
  void init() {}

  /// Cleans up when the model is removed from the [ModelStore].
  void dispose() {}
}
