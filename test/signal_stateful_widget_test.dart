import 'package:flutter_signal/src/signal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'pages_for_testing_widgets/signal_stateful_widget_test_page.dart';

void main() {
  testWidgets(
    'onDidUpdateWidget signals of SignalWidget being reconfigured properly',
        (tester) => signalReconnectionOnDidUpdateWidgetTest(tester),
  );
}

Future<void> signalReconnectionOnDidUpdateWidgetTest(WidgetTester tester) async {
  await tester.pumpWidget(const StatefulSignalWidgetTest());

  expect(SignalTester(signalOne).slots().length, 1, reason: 'Expected signalOne to have exactly one slot connected before test');
  expect(SignalTester(signalTwo).slots().length, 1, reason: 'Expected signalTwo to have exactly one slot connected before test');
  expect(SignalTester(signalThree).slots().length, 0, reason: 'Expected signalThree to have no slot connected before test');

  final signalReconnectionButton = find.byKey(const ValueKey('statefulSignalWidgetButton'));
  await tester.tap(signalReconnectionButton);
  await tester.pump();

  expect(SignalTester(signalOne).isThereSlotToBeRemoved(), true, reason: 'Expected signalOne to have one slot to be removed');
  expect(SignalTester(signalTwo).isThereSlotToBeRemoved(), false, reason: 'Expected signalTwo to have no slot to be removed');
  expect(SignalTester(signalThree).isThereSlotToBeRemoved(), false, reason: 'Expected signalThree to have no slot to be removed');
  expect(SignalTester(signalThree).isThereSlotTobeAdded(), true, reason: 'Expected signalThree to have one slot to be added');

  expect(SignalTester(signalOne).slots().length, 0, reason: 'Expected signalOne to have no slots since it is no more in slot set');
  expect(SignalTester(signalTwo).slots().length, 1, reason: 'Expected signalTwo to have exactly one slot since it is still in slot set');
  expect(SignalTester(signalThree).slots().length, 1, reason: 'Expected signalThree to have exactly one slot connected since it is now in slot set');
}