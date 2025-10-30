import 'package:flutter/material.dart';
import 'package:frost/signal.dart';
import 'package:frost/watcher.dart';

class SignalWidgetReparentTestPage extends StatelessWidget {
  const SignalWidgetReparentTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ReparentWidget(),
    );
  }
}

bool deactivateCalled = false;
bool activateCalled = false;
class ChildWidget extends StatelessWidget {
  const ChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Watcher(
      signal: Signal(),
      onDeactivate: () => deactivateCalled = true,
      onActivate: () => activateCalled = true,
      watch: (BuildContext context) {
        return const Text('test');
      },
    );
  }
}

class ReparentWidget extends StatefulWidget {
  const ReparentWidget({super.key});

  @override
  State<ReparentWidget> createState() => _ReparentWidgetState();
}

class _ReparentWidgetState extends State<ReparentWidget> {
  final _reparentKey = GlobalKey<_ReparentWidgetState>();
  bool _isReparented = false;

  void _reparent() {
    setState(() {
      _isReparented = !_isReparented;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isReparented
          ? Container(
              padding: const EdgeInsets.all(5.0),
              child: ChildWidget(
                key: _reparentKey,
              ),
            )
          : ChildWidget(
              key: _reparentKey,
            ),
      floatingActionButton: ElevatedButton(
        key: const ValueKey('reparentButton'),
        onPressed: _reparent,
        child: const Text('Reparent me'),
      ),
    );
  }
}
