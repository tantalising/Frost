import 'package:flutter/material.dart';
import 'package:frost/model_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'pages_for_testing_widgets/watcher_reparent_test_page.dart';
import 'pages_for_testing_widgets/watcher_test_page.dart';

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
}

Future<void> singleSignalTest(tester) async {
  final incrementButton = find.byKey(const ValueKey("incrementButton"));

  await tester.pumpWidget(const WatcherTest());
  await tester.tap(incrementButton);
  await tester.pump();

  expect(find.text('1'), findsOneWidget);
}

Future<void> multiSignalTest(tester) async {
  final incrementButton =
      find.byKey(const ValueKey("multiSignalIncrementButton"));

  await tester.pumpWidget(const WatcherTest());
  await tester.tap(incrementButton);
  await tester.pump();

  expect(find.text('6'), findsOneWidget);
  expect(find.text('11'), findsOneWidget);
}

Future<void> initCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const WatcherTest());
  expect(CountModel.get.initCalled, true);
}

Future<void> modelInitCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const WatcherTest());
  expect(CountModel.get.modelInitCalled, true);
}

Future<void> disposeCalledTest(WidgetTester tester) async {
  await _createAndDisposeSignalWidget(tester);
  expect(disposeCalled, true);
}

Future<void> activateCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const WatcherReparentTestPage());
  final reparentButton = find.byKey(const ValueKey('reparentButton'));
  await tester.tap(reparentButton);
  await tester.pump();
  expect(activateCalled, true);
}

Future<void> deactivateCalledTest(WidgetTester tester) async {
  await tester.pumpWidget(const WatcherReparentTestPage());
  final reparentButton = find.byKey(const ValueKey('reparentButton'));
  await tester.tap(reparentButton);
  await tester.pump();
  expect(deactivateCalled, true);
}

Future<void> _createAndDisposeSignalWidget(tester) async {
  // disposing mechanism found on SO.
  // I am not (yet) sure how it works.
  await tester.pumpWidget(const WatcherTest());
  await tester.pumpAndSettle();
  await tester.pumpWidget(Container());
  await tester.pumpAndSettle();
}
