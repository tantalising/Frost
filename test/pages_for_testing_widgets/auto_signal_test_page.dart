import 'package:flutter/material.dart';
import 'package:frost/model_store.dart';
import 'package:frost/signal.dart';
import 'package:frost/watcher.dart';

class AutoSignalModel extends SignalModel {
  int _count = 0;
  final countChanged = Signal();
  int _anotherCount = 0;
  final anotherCountChanged = Signal();

  int get count => getter(_count, countChanged);
  set count(int count) {
    if (_count == count) return;
    _count = count;
    countChanged();
  }

  int get anotherCount => getter(_anotherCount, anotherCountChanged);
  set anotherCount(int anotherCount) {
    if (_anotherCount == anotherCount) return;
    _anotherCount = anotherCount;
    anotherCountChanged();
  }

  static AutoSignalModel get get => ModelStore.get<AutoSignalModel>()!;
}

class AutoSignalTest extends StatelessWidget {
  const AutoSignalTest({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Watcher(
              watch: (_) => Text("The count is ${AutoSignalModel.get.count}"
                  " and the another count is ${AutoSignalModel.get.anotherCount}"),
            ),
            MaterialButton(
              key: const ValueKey('countButton'),
              onPressed: () => AutoSignalModel.get.count++,
              child: const Text('press me'),
            ),
            MaterialButton(
              key: const ValueKey('anotherCountButton'),
              onPressed: () => AutoSignalModel.get.anotherCount++,
              child: const Text('press me as well'),
            ),
          ],
        ),
      ),
    );
  }
}
