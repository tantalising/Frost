import 'package:flutter/material.dart';
import 'package:frost/watcher.dart';

final anotherCount = 5.property;
final yetAnotherCount = 10.property;

class AutoPropertyTest extends StatelessWidget {
  const AutoPropertyTest({super.key});

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
              watch: (_) => Text("The another count is ${anotherCount.value}"
                  " and the yet another count is ${yetAnotherCount.value}"),
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
    );
  }
}
