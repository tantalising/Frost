import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frost/property.dart';

void main() {
  test('Engine Benchmark: Property vs ValueNotifier (With Warm-Up)', () {
    const warmupIterations = 5000;
    const measuredIterations = 1000000;

    assert(warmupIterations < measuredIterations-1, 'oh no');

    print('--- LOGIC BENCHMARK (Warmup: $warmupIterations, Measured: $measuredIterations) ---');

    final notifier = ValueNotifier<int>(0);
    notifier.addListener(() {});

    final property = 0.property;
    property.changed.connect(() {});

    // =========================================================================
    // 1. WARM UP PHASE (Crucial for JIT optimization)
    // =========================================================================

    // Warm up ValueNotifier
    for (var i = 0; i < warmupIterations; i++) {
      notifier.value = i;
    }

    // Warm up Frost
    for (var i = 0; i < warmupIterations; i++) {
      property.value = i;
    }

    // =========================================================================
    // 2. MEASURE VALUELISTENABLE (Standard)
    // =========================================================================
    final stopwatchVN = Stopwatch()..start();
    for (var i = warmupIterations+1; i < measuredIterations; i++) {
      notifier.value = i;
    }
    stopwatchVN.stop();
    print('ValueNotifier : ${stopwatchVN.elapsedMilliseconds}ms');

    // =========================================================================
    // 3. MEASURE FROST (Candidate)
    // =========================================================================
    final stopwatchFrost = Stopwatch()..start();
    for (var i = warmupIterations+1; i < measuredIterations; i++) {
      property.value = i;
    }
    stopwatchFrost.stop();
    print('Frost Property: ${stopwatchFrost.elapsedMilliseconds}ms');

    // =========================================================================
    // COMPARISON
    // =========================================================================
    final vnTime = stopwatchVN.elapsedMilliseconds == 0 ? 1 : stopwatchVN.elapsedMilliseconds;
    final frostTime = stopwatchFrost.elapsedMilliseconds;

    // Calculate how much slower Frost is compared to VN (1.0x = same speed)
    final ratio = frostTime / vnTime;

    print('---------------------------------------------------');
    print('Result: Frost is ${ratio.toStringAsFixed(2)}x the duration of ValueNotifier');

    // Adjusted thresholds for pure logic (Logic usually needs to be tighter than widgets)
    if (ratio <= 1.2) {
      print('✅ Status: EXCELLENT (Negligible overhead)');
    } else if (ratio <= 2.5) {
      print('⚠️ Status: GOOD (Acceptable for most UIs)');
    } else {
      print('❌ Status: HEAVY (Might lag in tight loops)');
    }
    print('---------------------------------------------------\n');
  });
}