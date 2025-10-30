import 'package:flutter/material.dart';
import 'package:frost/property_widget.dart';
import 'package:frost/signal.dart';

final count = 0.property;
final anotherCount = 5.property;
final yetAnotherCount = 10.property;

//these properties are kept in sync. in the widget we cannot directly use
// the properties because they will be automatically connected to rebuild.
//here we testing if externally supplied properties are triggering rebuild.
//so we need to read their values in an indirect way.

var count_mirror = 0;
var anotherCount_mirror = 5;
var yetAnotherCount_mirror = 10;


var initCalled = false;
var disposeCalled = false;

class PropertyWidgetTest extends StatelessWidget {
  const PropertyWidgetTest({super.key});

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
              onInit: () => initCalled = true,
              onDispose: () => disposeCalled = true,
              property: count,
              watch: (context) => Text(
                "$count_mirror",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Watcher(
              onInit: () {
                //we have to connect the mirror variables somewhere. this seems to be a nice place.
                connect(count.changed, () => count_mirror = count.value);
                connect(anotherCount.changed, () => anotherCount_mirror = anotherCount.value);
                connect(yetAnotherCount.changed, () => yetAnotherCount_mirror = yetAnotherCount.value);
              },
              properties: {anotherCount, yetAnotherCount},
              watch: (_) => Text("The another count is $anotherCount_mirror"
                  " and the yet another count is $yetAnotherCount_mirror"),
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
