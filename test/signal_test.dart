import 'package:test/test.dart';
import 'package:frost/signal.dart';

void main() {
  group("signal test", () {
    test("connection test", testConnection);
    test("emission test", testEmission);
    test("disconnection test", testDisconnection);
    test("emission with argument test", testArgument);
    test('test removal while iterating does\'nt break',
        testRemovalWhileIteration);
    test('test addition while iterating does\'nt break', testAdditionWhileIteration);
  });

  group("signal methods test", () {
    test("connection test", testConnectionMethod);
    test("disconnection test", testDisconnectionMethod);
  });
}

final signalTestValueChanged = Signal();

class SignalTest {
  late int _value;
  int numberOfTimesSlotCalled = 0;
  SignalTest(int value) {
    _value = value;
  }
  set value(int newValue) {
    _value = newValue;
    signalTestValueChanged();
  }

  void resetNumberOfTimesSlotCalled() {
    numberOfTimesSlotCalled = 0;
  }

  int get value => _value;
  Slot signalEmitted() {
    numberOfTimesSlotCalled++;
  }
}

class EmitWithArgumentTest {
  static final argumentChanged = Signal();
  var argumentPassed = "";
  Slot slotWithArgument(String arg) {
    argumentPassed = arg;
  }
}

void testConnection() {
  final signalTest = SignalTest(0);
  connect(signalTestValueChanged, signalTest.signalEmitted);
  signalTest.value++;
  expect(1, signalTest.numberOfTimesSlotCalled);
}

void testEmission() {
  final signalTest = SignalTest(0);
  connect(signalTestValueChanged, signalTest.signalEmitted);
  signalTestValueChanged();
  expect(1, signalTest.numberOfTimesSlotCalled);
}

void testDisconnection() {
  final signalTest = SignalTest(0);
  connect(signalTestValueChanged, signalTest.signalEmitted);
  signalTest.value++;
  disconnect(signalTestValueChanged, signalTest.signalEmitted);
  signalTest.value++;

  expect(2, signalTest.value);
  expect(1, signalTest.numberOfTimesSlotCalled);
}

void testArgument() {
  final emitTest = EmitWithArgumentTest();
  const matchString = "match this string";
  connect(EmitWithArgumentTest.argumentChanged, emitTest.slotWithArgument);
  EmitWithArgumentTest.argumentChanged(matchString);
  EmitWithArgumentTest.argumentChanged(matchString);

  expect(emitTest.argumentPassed, matchString);
}

void testConnectionMethod() {
  final signalTest = SignalTest(0);
  signalTestValueChanged.connect(signalTest.signalEmitted);
  signalTest.value++;
  expect(1, signalTest.numberOfTimesSlotCalled);
}

void testDisconnectionMethod() {
  final signalTest = SignalTest(0);
  signalTestValueChanged.connect(signalTest.signalEmitted);
  signalTest.value++;
  disconnect(signalTestValueChanged, signalTest.signalEmitted);
  signalTestValueChanged.disconnect(signalTest.signalEmitted);
  signalTest.value++;

  expect(2, signalTest.value);
  expect(1, signalTest.numberOfTimesSlotCalled);
}

void testRemovalWhileIteration() {
  int count1 = 0;
  int count2 = 0;
  final increment = Signal();
  slot1() => count1++;
  slot2() {
    count2++;
    increment.disconnect(slot1);
  }

  increment.connect(slot1);
  increment.connect(slot2);

  expect(count1, 0, reason: 'count1 is not zero at start');
  expect(count2, 0, reason: 'count2 is not zero at start');

  increment();
  expect(count1, 1, reason: 'should be 1 after first increment call');
  expect(count2, 1, reason: 'should be 1 after first increment call');

  increment();
  expect(count1, 1, reason: 'should be still 1 after second increment call');
  expect(count2, 2, reason: 'should be 2 after second increment call');
}

void testAdditionWhileIteration() {
  int count1 = 0;
  int count2 = 0;
  final increment = Signal();
  slot1() => count1++;
  slot2() {
    count2++;
    increment.connect(slot1);
  }

  increment.connect(slot2);

  expect(count1, 0, reason: 'count1 is not zero at start');
  expect(count2, 0, reason: 'count2 is not zero at start');

  increment();
  expect(count1, 0, reason: 'should be 0 after first increment call');
  expect(count2, 1, reason: 'should be 1 after first increment call');

  increment();
  expect(count1, 1, reason: 'should be 1 after second increment call');
  expect(count2, 2, reason: 'should be 2 after second increment call');
}
