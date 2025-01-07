import 'package:flutter/material.dart';
import 'package:flutter_signal/signal_model.dart';
import 'package:flutter_signal/signal_widget.dart';

bool disposeCalled = false;
bool didChangeDependenciesCalled = false;
bool didUpdateWidgetCalled = false;

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

void main() {
  runApp(const SignalWidgetTest());
}

class SignalWidgetTest extends StatelessWidget {
  const SignalWidgetTest({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
  var _customTheme = ThemeData(primaryColor: Colors.green);
  void _changeTheme() {
    setState(() {
      _customTheme = ThemeData(primaryColor: Colors.red);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Theme(
            data: _customTheme,
            child: SignalWidget(
              onInit: () => CountModel.get.initCalled = true,
              onDispose: () => disposeCalled = true,
              onDidChangeDependencies: () => didChangeDependenciesCalled = true,
              onDidUpdateWidget: (_) => didUpdateWidgetCalled = true,
              signal: CountModel.countChanged,
              model: CountModel(),
              builder: (context) => Text(
                CountModel.get.count.toString(),
              ),
            ),
          ),
          SignalWidget<CountModel>(
            signals: {
              CountModel.anotherCountChanged,
              CountModel.yetAnotherCountChanged
            },
            // only one floating button so place other buttons here
            builder: (_) => Column(
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
                MaterialButton(
                  key: const ValueKey('updateWidgetButton'),
                  onPressed: () => setState(() {}),
                ),
                MaterialButton(
                  key: const ValueKey('changeDependencyButton'),
                  onPressed: _changeTheme,
                ),
              ],
            ),
          ),
          // Test proper reconnection of signals on didUpdateWidget
          SignalWidget(
            signals: signalSet,
            builder: (_) => MaterialButton(
              key: const ValueKey('multiSignalReconnectionButton'),
              onPressed: () => setState(
                () {
                  signalSet = signalSetTwo;
                },
              ),
            ),
          ),
          // Test proper reconnection of single signal on didUpdateWidget
          SignalWidget(
            signal: signal,
            builder: (_) => Column(
              children: [
                MaterialButton(
                  key: const ValueKey('singleSignalReconnectionButton'),
                  onPressed: () => setState(
                        () {
                      signal = singleSignalTwo;
                    },
                  ),
                ),
                MaterialButton(
                  key: const ValueKey('singleSignalNoReconnectionButton'),
                  onPressed: () => setState(
                        () {
                      signal = singleSignalTwo;
                    },
                  ),
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
