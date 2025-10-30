import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pages_for_testing_widgets/auto_property_test_page.dart';

void main() {
  testWidgets(
      'Given builder with properties inside test whether the properties change triggers rebuild',
      (tester) => testPropertiesChangeTriggersRebuild(tester));
}

Future<void> testPropertiesChangeTriggersRebuild(WidgetTester tester) async {
  final anotherCountButton = find.byKey(const ValueKey('anotherCountButton'));
  final yetAnotherCountButton =
      find.byKey(const ValueKey('yetAnotherCountButton'));

  await tester.pumpWidget(const AutoPropertyTest());

  await tester.tap(anotherCountButton);
  await tester.pump();

  expect(
      find.text("The another count is 6"
          " and the yet another count is 10"),
      findsOneWidget);

  await tester.tap(yetAnotherCountButton);
  await tester.pump();

  expect(
      find.text("The another count is 6"
          " and the yet another count is 11"),
      findsOneWidget);
}