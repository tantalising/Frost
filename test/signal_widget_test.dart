import 'package:flutter/material.dart';
import 'package:flutter_signal/signal_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'pages_for_testing_widgets/signal_widget_reparent_test_page.dart';
import 'pages_for_testing_widgets/signal_widget_test_page.dart';

void main() {
  setUp(() => ModelStore.clear()); // empty the store before every test.
  testWidgets("signal widget test", (tester) => singleSignalTest(tester));
  testWidgets(
    "multiple signals widget test",
    (tester) => multiSignalTest(tester),
  );
  testWidgets(
    "init passed to signal widget being called test",
    (tester) => initCalledTest(tester),
  );
  testWidgets(
    "init part of model being called test",
    (tester) => modelInitCalledTest(tester),
  );
  testWidgets(
    "dispose passed to signal widget being called test",
    (tester) => disposeCalledTest(tester),
  );
  testWidgets(
    'OnDeactivate callback of SignalWidget being called test',
    (tester) => deactivateCalledTest(tester),
  );
  testWidgets(
    'OnActivate callback of SignalWidget being called test',
    (tester) => activateCalledTest(tester),
  );

  testWidgets(
    'onDidUpdateWidget callback of SignalWidget being called test',
    (tester) => didUpdateWidgetCalledTest(tester),
  );
  testWidgets(
    'onDidChangeDependencies callback of SignalWidget being called test',
    (tester) => didChangeDependenciesCalledTest(tester),
  );

  testWidgets(
    'onDidUpdateWidget signals of SignalWidget being reconfigured properly',
        (tester) => multiSignalReconnectionOnDidUpdateWidgetTest(tester),
  );

  testWidgets(
    'onDidUpdateWidget signal of SignalWidget being reconfigured properly',
        (tester) => singleSignalReconnectionOnDidUpdateWidgetTest(tester),
  );
}

Future<void> singleSignalTest(tester) async {
  final incrementButton = find.byKey(const ValueKey("incrementButton"));

  await tester.pumpWidget(const SignalWidgetTest());
  await tester.tap(incrementButton);
  await tester.pump();

  expect(find.text('1'), findsOneWidget);
}

Future<void> multiSignalTest(tester) async {
  final incrementButton =
      find.byKey(const ValueKey("multiSignalIncrementButton"));

  await tester.pumpWidget(const SignalWidgetTest());
  await tester.tap(incrementButton);
  await tester.pump();

  expect(find.text('6'), findsOneWidget);
  expect(find.text('11'), findsOneWidget);
}

Future<void> initCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const SignalWidgetTest());
  expect(CountModel.get.initCalled, true);
}

Future<void> modelInitCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const SignalWidgetTest());
  expect(CountModel.get.modelInitCalled, true);
}

Future<void> disposeCalledTest(WidgetTester tester) async {
  await _createAndDisposeSignalWidget(tester);
  expect(disposeCalled, true);
}

Future<void> activateCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const SignalWidgetReparentTestPage());
  final reparentButton = find.byKey(const ValueKey('reparentButton'));
  await tester.tap(reparentButton);
  await tester.pump();
  expect(activateCalled, true);
}

Future<void> deactivateCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const SignalWidgetReparentTestPage());
  final reparentButton = find.byKey(const ValueKey('reparentButton'));
  await tester.tap(reparentButton);
  await tester.pump();
  expect(deactivateCalled, true);
}

Future<void> didUpdateWidgetCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const SignalWidgetTest());
  final updateWidgetButton = find.byKey(const ValueKey('updateWidgetButton'));
  await tester.tap(updateWidgetButton);
  await tester.pump();
  expect(didUpdateWidgetCalled, true);
}

Future<void> didChangeDependenciesCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const SignalWidgetTest());
  final changeDependencyButton =
      find.byKey(const ValueKey('changeDependencyButton'));
  await tester.tap(changeDependencyButton);
  await tester.pump();
  expect(didChangeDependenciesCalled, true);
}

Future<void> multiSignalReconnectionOnDidUpdateWidgetTest(WidgetTester tester) async {
  await tester.pumpWidget(const SignalWidgetTest());

  expect(SignalTester(signalOne).slots().length, 1, reason: 'Expected signalOne to have exactly one slot connected before test');
  expect(SignalTester(signalTwo).slots().length, 1, reason: 'Expected signalTwo to have exactly one slot connected before test');
  expect(SignalTester(signalThree).slots().length, 0, reason: 'Expected signalThree to have no slot connected before test');

  final multiSignalReconnectionButton = find.byKey(const ValueKey('multiSignalReconnectionButton'));
  await tester.tap(multiSignalReconnectionButton);
  await tester.pump();

  expect(SignalTester(signalOne).isThereSlotToBeRemoved(), true, reason: 'Expected signalOne to have one slot to be removed');
  expect(SignalTester(signalTwo).isThereSlotToBeRemoved(), false, reason: 'Expected signalTwo to have no slot to be removed');
  expect(SignalTester(signalThree).isThereSlotToBeRemoved(), false, reason: 'Expected signalThree to have no slot to be removed');
  expect(SignalTester(signalThree).isThereSlotTobeAdded(), true, reason: 'Expected signalThree to have one slot to be added');

  expect(SignalTester(signalOne).slots().length, 0, reason: 'Expected signalOne to have no slots since it is no more in slot set');
  expect(SignalTester(signalTwo).slots().length, 1, reason: 'Expected signalTwo to have exactly one slot since it is still in slot set');
  expect(SignalTester(signalThree).slots().length, 1, reason: 'Expected signalThree to have exactly one slot connected since it is now in slot set');
}

Future<void> singleSignalReconnectionOnDidUpdateWidgetTest(WidgetTester tester) async {
  await tester.pumpWidget(const SignalWidgetTest());
  expect(SignalTester(singleSignalOne).slots().length, 1, reason: 'Expected singleSignalOne to have exactly one slot connected before test');
  expect(SignalTester(singleSignalTwo).slots().length, 0, reason: 'Expected singleSignalTwo to have no slot connected before test');

  final singleSignalReconnectionButton = find.byKey(const ValueKey('singleSignalReconnectionButton'));
  await tester.tap(singleSignalReconnectionButton);
  await tester.pump();

  expect(SignalTester(singleSignalOne).isThereSlotToBeRemoved(), true, reason: 'Expected singleSignalOne to have one slot to be removed');
  expect(SignalTester(singleSignalTwo).isThereSlotTobeAdded(), true, reason: 'Expected singleSignalTwo to have one slot to be added');

  expect(SignalTester(singleSignalOne).slots().length, 0, reason: 'Expected singleSignalOne to have no slot connected after didUpdateWidget called');
  expect(SignalTester(singleSignalTwo).slots().length, 1, reason: 'Expected singleSignalTwo to have exactly one slot after didUpdateWidget called');

  final singleSignalNoReconnectionButton = find.byKey(const ValueKey('singleSignalNoReconnectionButton'));
  await tester.tap(singleSignalNoReconnectionButton);
  await tester.pump();

  // Absolutely nothing should change now. Let's test.
  expect(SignalTester(singleSignalOne).isThereSlotTobeAdded(), false, reason: 'Expected singleSignalOne to have no slot to be added');
  expect(SignalTester(singleSignalOne).isThereSlotToBeRemoved(), false, reason: 'Expected singleSignalOne to have no slot to be removed');
  expect(SignalTester(singleSignalTwo).isThereSlotTobeAdded(), false, reason: 'Expected singleSignalTwo to have no slot to be added');
  expect(SignalTester(singleSignalTwo).isThereSlotToBeRemoved(), false, reason: 'Expected singleSignalTwo to have no slot to be removed');
}

Future<void> _createAndDisposeSignalWidget(tester) async {
  // disposing mechanism found on SO.
  // I am not (yet) sure how it works.
  await tester.pumpWidget(const SignalWidgetTest());
  await tester.pumpAndSettle();
  await tester.pumpWidget(Container());
  await tester.pumpAndSettle();
}
