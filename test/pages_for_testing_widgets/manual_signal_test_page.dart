import 'package:flutter/material.dart';
import 'package:frost/model_store.dart';
import 'package:frost/signal.dart';
import 'package:frost/watcher.dart';

class ManualSignalModel extends Model {
  int _count = 0;
  final countChanged = Signal();
  int _anotherCount = 0;
  final anotherCountChanged = Signal();

  int get count => _count;
  set count(int count) {
    if (_count == count) return;
    _count = count;
    countChanged();
  }

  int get anotherCount => _anotherCount;
  set anotherCount(int anotherCount) {
    if (_anotherCount == anotherCount) return;
    _anotherCount = anotherCount;
    anotherCountChanged();
  }

  static ManualSignalModel get get => Store.get<ManualSignalModel>()!;
}

class ManualSignalTest extends StatelessWidget {
  const ManualSignalTest({super.key});

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
              signal: ManualSignalModel.get.countChanged,
              signals: {ManualSignalModel.get.anotherCountChanged},
              watch: (_) => Text("The count is ${ManualSignalModel.get.count}"
                  " and the another count is ${ManualSignalModel.get.anotherCount}"),
            ),
            MaterialButton(
              key: const ValueKey('countButton'),
              onPressed: () => ManualSignalModel.get.count++,
              child: const Text('press me'),
            ),
            MaterialButton(
              key: const ValueKey('anotherCountButton'),
              onPressed: () => ManualSignalModel.get.anotherCount++,
              child: const Text('press me as well'),
            ),
          ],
        ),
      ),
    );
  }
}
