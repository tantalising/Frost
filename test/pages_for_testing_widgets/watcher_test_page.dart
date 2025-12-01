import 'package:flutter/material.dart';
import 'package:frost/store.dart';
import 'package:frost/model.dart';
import 'package:frost/watcher.dart';

bool disposeCalled = false;
class CountModel extends Model {
  bool initCalled = false;
  bool modelInitCalled = false;

  static CountModel get get {
    final model = Store.get<CountModel>();
    if (model != null) {
      return model;
    } else {
      throw 'Could not find a CountModel';
    }
  }

  @override
  void init() {
    modelInitCalled = true;
  }
}

class WatcherTest extends StatelessWidget {
  const WatcherTest({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Store.add(()=>CountModel());
    return const MaterialApp(
      home: MyHomePage(title: 'Test Page'),
    );
  }
}

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
            watch: (context) => Text(
              'afd'
            ),
          ),
        ],
      ),
    );
  }
}
