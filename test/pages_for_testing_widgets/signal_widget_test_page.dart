import 'package:flutter/material.dart';
import 'package:frost/model_store.dart';
import 'package:frost/signal_model.dart';
import 'package:frost/watcher.dart';

bool disposeCalled = false;
class CountModel extends SignalModel {
  int _counter = 0;
  int _anotherCounter = 5;
  int _yetAnotherCounter = 10;

  bool initCalled = false;
  bool modelInitCalled = false;

  static final countChanged = Signal();
  static final anotherCountChanged = Signal();
  static final yetAnotherCountChanged = Signal();

  static CountModel get get {
    final model = ModelStore.get<CountModel>();
    if (model != null) {
      return model;
    } else {
      throw 'Could not find a CountModel';
    }
  }

  int get count => _counter;
  int get anotherCount => _anotherCounter;
  int get yetAnotherCount => _yetAnotherCounter;

  void incrementCount() {
    _counter++;
    countChanged();
  }

  void incrementAnotherCount() {
    _anotherCounter++;
    anotherCountChanged();
  }

  void incrementYetAnotherCount() {
    _yetAnotherCounter++;
    yetAnotherCountChanged();
  }

  @override
  void init() {
    modelInitCalled = true;
  }
}

class SignalWidgetTest extends StatelessWidget {
  const SignalWidgetTest({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ModelStore.add(()=>CountModel());
    return const MaterialApp(
      home: MyHomePage(title: 'Test Page'),
    );
  }
}

final signalOne = Signal();
final signalTwo = Signal();
final signalThree = Signal();

final singleSignalOne = Signal();
final singleSignalTwo = Signal();

final signalSetOne = {signalOne, signalTwo};
final signalSetTwo = {signalTwo, signalThree};

var signalSet = signalSetOne;
var signal = singleSignalOne;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Watcher(
            onInit: () => CountModel.get.initCalled = true,
            onDispose: () => disposeCalled = true,
            signal: CountModel.countChanged,
            watch: (context) => Text(
              CountModel.get.count.toString(),
            ),
          ),
          Watcher(
            signals: {
              CountModel.anotherCountChanged,
              CountModel.yetAnotherCountChanged
            },
            // only one floating button so place other buttons here
            watch: (_) => Column(
              children: [
                Text(CountModel.get.anotherCount.toString()),
                Text(CountModel.get.yetAnotherCount.toString()),
                MaterialButton(
                  key: const ValueKey("multiSignalIncrementButton"),
                  onPressed: () {
                    CountModel.get.incrementAnotherCount();
                    CountModel.get.incrementYetAnotherCount();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey("incrementButton"),
        onPressed: () => CountModel.get.incrementCount(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
