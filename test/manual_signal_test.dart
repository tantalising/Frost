import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frost/model_store.dart';

import 'pages_for_testing_widgets/manual_signal_test_page.dart';

void main() {
  setUp(() => Store.clear());
  testWidgets(
      'Given builder model data inside test whether the data change triggers rebuild when signals are connected',
      (tester) => signalEmissionTriggersRebuild(tester));
}

Future<void> signalEmissionTriggersRebuild(WidgetTester tester) async {
  Store.add(() => ManualSignalModel());
  final countButton = find.byKey(const ValueKey('countButton'));
  final anotherCountButton =
      find.byKey(const ValueKey('anotherCountButton'));

  await tester.pumpWidget(const ManualSignalTest());

  await tester.tap(countButton);
  await tester.pump();

  expect(
      find.text("The count is 1"
          " and the another count is 0"),
      findsOneWidget);

  await tester.tap(anotherCountButton);
  await tester.pump();

  expect(
      find.text("The count is 1"
          " and the another count is 1"),
      findsOneWidget);
}