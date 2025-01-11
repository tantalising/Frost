import 'package:flutter/material.dart';
import 'package:flutter_signal/src/signal.dart';
import 'package:flutter_signal/src/signal_stateful_widget.dart';

final signalOne = Signal();
final signalTwo = Signal();
final signalThree = Signal();

final signalSetOne = {signalOne, signalTwo};
final signalSetTwo = {signalTwo, signalThree};

var signalSet = signalSetOne;

class StatefulSignalWidget extends SignalStatefulWidget {
  StatefulSignalWidget({super.key}): super(signals: signalSet);

  @override
  SignalState<StatefulSignalWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends SignalState<StatefulSignalWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StatefulSignalWidgetTest extends StatefulWidget {
  const StatefulSignalWidgetTest({super.key});

  @override
  State<StatefulSignalWidgetTest> createState() =>
      _StatefulSignalWidgetTestState();
}

class _StatefulSignalWidgetTestState extends State<StatefulSignalWidgetTest> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatefulSignalWidget(),
        Directionality(
          textDirection: TextDirection.ltr,
          child: MaterialButton(
            key: const ValueKey('statefulSignalWidgetButton'),
            onPressed: () => setState(() {
              signalSet = signalSetTwo;
            }),
          ),
        ),
      ],
    );
  }
}
