import 'package:test/test.dart';
import 'package:flutter_signal/signal.dart';

void main() {
  group("signal test", () {
    test("connection test", testConnection);
    test("emission test", testEmission);
    test("disconnection test", testDisconnection);
    test("emission with argument test", testArgument);
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




