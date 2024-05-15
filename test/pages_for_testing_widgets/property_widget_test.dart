import 'package:flutter/material.dart';
import 'package:flutter_signal/signal.dart';

void main() {
  runApp(const PropertyWidgetTest());
}

final count = 0.property;
final anotherCount = 5.property;
final yetAnotherCount = 10.property;

class PropertyWidgetTest extends StatelessWidget {
  const PropertyWidgetTest({super.key});

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
            PropertyWidget(
              property: count,
              builder: () => Text(
                count.value.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            PropertyWidget(
              properties: {anotherCount, yetAnotherCount},
              builder: () => Text("The another count is ${anotherCount.value.toString()}"
                  " and the yet another count is ${yetAnotherCount.value.toString()}"),
            ),
            MaterialButton(
              key: const ValueKey('anotherCountButton'),
              onPressed: () => anotherCount.value++,
              child: const Text('press me'),
            ),
            MaterialButton(
              key: const ValueKey('yetAnotherCountButton'),
              onPressed: () => yetAnotherCount.value++,
              child: const Text('press me as well'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey("incrementButton"),
        onPressed: () => count.value++,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
