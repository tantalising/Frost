import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pages_for_testing_widgets/property_widget_test.dart';

void main() {
  testWidgets(
      "given a property to property widget test whether the property change triggers rebuild",
      (tester) => testPropertyChangeTriggersRebuild(tester));

  testWidgets(
      "given multiple properties to property widget test whether the properties change triggers rebuild",
          (tester) => testPropertiesChangeTriggersRebuild(tester));
}

Future<void> testPropertyChangeTriggersRebuild(WidgetTester tester) async {
  final incrementButton = find.byKey(const ValueKey('incrementButton'));

  await tester.pumpWidget(const PropertyWidgetTest());
  await tester.tap(incrementButton);
  await tester.pump();

  expect(find.text('1'), findsOneWidget);
}

Future<void> testPropertiesChangeTriggersRebuild(WidgetTester tester) async {
  final anotherCountButton = find.byKey(const ValueKey('anotherCountButton'));
  final yetAnotherCountButton = find.byKey(const ValueKey('yetAnotherCountButton'));

  await tester.pumpWidget(const PropertyWidgetTest());

  await tester.tap(anotherCountButton);
  await tester.pump();

  expect(find.text("The another count is 6"
      " and the yet another count is 10"), findsOneWidget);

  await tester.tap(yetAnotherCountButton);
  await tester.pump();

  expect(find.text("The another count is 6"
      " and the yet another count is 11"), findsOneWidget);
}
