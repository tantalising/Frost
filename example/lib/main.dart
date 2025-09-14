import 'package:flutter/material.dart';
import 'package:frost/signal_widget.dart';
import 'package:frost/model_store.dart';
import 'model.dart';

Slot doSomething() {
  print('doing something');
}

void main() {
  connect(CountModel.countChanged, doSomething);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            SignalWidget(
              signal: CountModel.countChanged,
              model: CountModel(),
              builder: (context) => Text(
                ModelStore.get<CountModel>()!.count.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ModelStore.get<CountModel>()?.incrementCount(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}




