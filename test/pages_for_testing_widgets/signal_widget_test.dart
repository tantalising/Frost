import 'package:flutter/material.dart';
import 'package:flutter_signal/signal.dart';

bool disposeCalled = false; // global so that it doesn't go away with the
// model when the widget is disposed. SignalWidget disposes models passed to
// it when it itself get disposed but we need to verify that the onDispose
// callback is also being called. So this variable will be changed when the
// the call is made.

// for same reason
bool modelDisposeCalled = false;

class CountModel implements SignalModel {
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
  void dispose() {
    modelDisposeCalled = true;
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            SignalWidget<CountModel>(

              onInit: () => CountModel.get.initCalled = true,
              onDispose: () => disposeCalled = true,

              signal: CountModel.countChanged,
              model: CountModel(),

              builder: () => Text(
                CountModel.get.count.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),

            ),
            SignalWidget<CountModel>(
              signals: {
                CountModel.anotherCountChanged,
                CountModel.yetAnotherCountChanged
              },
              builder: () => Column(
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
