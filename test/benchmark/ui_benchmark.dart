import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frost/watcher.dart';

void main() {
  final countProperty = 0.property;
  final countNotifier = ValueNotifier(0);

  testWidgets('Benchmark: Watcher vs ValueListenableBuilder (With Warm-Up)', (tester) async {
    const warmupUpdates = 2000;
    const measuredUpdates = 10000;
    assert(warmupUpdates < measuredUpdates-1, 'oh no');

    print('\nSTARTING BENCHMARK (Warmup: $warmupUpdates, Measured: $measuredUpdates)');

    // =========================================================================
    // 1. WARM UP (Runs code but doesn't time it)
    // =========================================================================

    // Warm up Watcher
    await tester.pumpWidget(MaterialApp(
      home: Watcher(watch: (_) => Text('${countProperty.value}')),
    ));
    for (var i = 0; i < warmupUpdates; i++) {
      countProperty.value = i;
      await tester.pump();
    }

    // Warm up VLB
    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<int>(
        valueListenable: countNotifier,
        builder: (_, val, __) => Text('$val'),
      ),
    ));
    for (var i = 0; i < warmupUpdates; i++) {
      countNotifier.value = i;
      await tester.pump();
    }

    // =========================================================================
    // 2. MEASURE WATCHER
    // =========================================================================
    await tester.pumpWidget(MaterialApp(
      home: Watcher(watch: (_) => Text('Val: ${countProperty.value}')),
    ));

    final stopwatchWatcher = Stopwatch()..start();
    for (var i = warmupUpdates+1; i < measuredUpdates; i++) {
      countProperty.value = i;
      await tester.pump();
    }
    stopwatchWatcher.stop();
    print('Watcher Time: ${stopwatchWatcher.elapsedMilliseconds}ms');

    // =========================================================================
    // 3. MEASURE VALUELISTENABLEBUILDER
    // =========================================================================
    await tester.pumpWidget(Container()); // Clear tree
    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<int>(
        valueListenable: countNotifier,
        builder: (_, val, __) => Text('Val: $val'),
      ),
    ));

    final stopwatchVLB = Stopwatch()..start();
    for (var i = warmupUpdates+1; i < measuredUpdates; i++) {
      countNotifier.value = i;
      await tester.pump();
    }
    stopwatchVLB.stop();
    print('VLB Time    : ${stopwatchVLB.elapsedMilliseconds}ms');

    // =========================================================================
    // COMPARISON
    // =========================================================================
    final ratio = stopwatchWatcher.elapsedMilliseconds / stopwatchVLB.elapsedMilliseconds;
    print('Ratio: ${ratio.toStringAsFixed(2)}x');
  });
}