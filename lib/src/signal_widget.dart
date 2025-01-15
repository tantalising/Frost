import 'package:flutter/material.dart';
import 'model_store.dart';
import 'signal.dart';
import 'signal_model.dart';

/// A widget intended to be used with signals.
///
/// It automatically rebuilds when one of the provided signals
/// are emitted.
/// The constructor takes an optional model argument. This way the
/// [SignalModel.dispose] and [SignalModel.init] can automatically
/// be called at appropriate times, init is called when it is passed to
/// this widget and dispose is called when the widget's own dispose method
/// is called.
/// The passed model can be accessed inside the [SignalWidget.builder] using
/// following way:
/// ```dart
///   final myModel = ModelStore.get<ModelType>();
/// ```
/// Or you can create a convenient model getter inside your model in this
/// manner.
/// ```dart
///     static MyModel get get {
///        final model = ModelStore.get<MyModel>();
///       if(model == null) {
///       // You might return the model as well instead of throwing
///       // and use null check operator instead. I do this just for
///       // for a cleaner look when using this method(no ! sign in the code).
///         throw("MyModel not found");
///       }
///        return model;
///      }
/// ```
/// Now you can access the model in this way:
/// ```dart
/// final model = MyModel.get;
/// //or use it directly
/// MyModel.get.myModelFields;
/// ```
/// Let us assume you have a model that holds an integer(count) and your ui shows
/// the current value of the count. The model may look like this:
/// ```dart
///class CountModel extends SignalModel {
///     static final countChanged = Signal();
///
///     //model Accessor
///      static CountModel get get {
///        final model = ModelStore.get<CountModel>();
///        if(model == null) {
///          throw("CountModel not found");
///        }
///        return model;
///      }
///
///      //main parts
///      void incrementCount() {
///        _counter++;
///        countChanged();
///      }
///      int get count => _counter;
///
///      int _counter = 0;
/// }
/// ```
/// When the user changes the value, the user interface should be updated.
/// This can be implemented in the following way:
/// ```dart
///        SignalWidget(
///           signal: CountModel.countChanged,
///           model: CountModel(),
///           builder: (context) => Text(
///            CountModel.get.count.toString(), //<-- model being accessed
///            style: Theme.of(context).textTheme.headlineMedium,
///             ),
///           ),
/// ```
///
/// See [ModelStore] class to know more about managing models manually.
class SignalWidget<T extends SignalModel> extends StatefulWidget {
  /// The widget to be built by this widget.
  final Widget Function(BuildContext context) builder;

  /// Signals which when emitted rebuilds the widget.
  final Set<Signal>? signals;

  /// Singular variant of [SignalWidget.signals] for aesthetic purposes.
  final Signal? signal;

  /// A callback which does some work when the widget is created.
  final VoidCallback? onInit;

  /// A callback which does some work when the widget is disposed.
  final VoidCallback? onDispose;

  /// A callback which is called when this widget is reinserted into the tree after having been
  /// removed via deactivate method of the state object of this widget.
  final VoidCallback? onActivate;

  /// A callback which is called when the deactivate method of this widget's state is called.
  final VoidCallback? onDeactivate;

  SignalWidget({
    this.signals,
    required this.builder,
    this.signal,

    /// The optional model to be used by this widget.
    T? model,
    this.onInit,
    this.onDispose,
    this.onActivate,
    this.onDeactivate,
  }):super(key: UniqueKey()) {
    assert(signal != null || signals != null,
        'SignalWidget: Provide value for at least one of signal or signals parameter');

    if (model != null) {
      ModelStore.add<T>(() => model);
    }
  }

  @override
  State<StatefulWidget> createState() => _SignalWidgetState<T>();
}

class _SignalWidgetState<T extends SignalModel> extends State<SignalWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  @override
  void initState() {
    final signals = {...?widget.signals, widget.signal}.whereType<Signal>();

    for (final signal in signals) {
      connect(signal, _rebuild);
    }
    widget.onInit?.call();
    super.initState();
  }

  @override
  void deactivate() {
    widget.onDeactivate?.call();
    super.deactivate();
  }

  @override
  void activate() {
    widget.onActivate?.call();
    super.activate();
  }

  @override
  void dispose() {
    widget.signal?.disconnect(_rebuild);

    final signals = widget.signals ?? {};
    for (final signal in signals) {
      signal.disconnect(_rebuild);
    }

    widget.onDispose?.call();
    super.dispose();
  }

  Slot _rebuild() {
    setState(() {});
  }
}