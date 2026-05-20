import 'package:flutter/material.dart';
import 'package:system_breakdown/src/rust/api/process.dart';

class ProcessesPage extends StatefulWidget {
  const ProcessesPage({super.key});

  @override
  State<ProcessesPage> createState() => _ProcessesPageState();
}

class _ProcessesPageState extends State<ProcessesPage> {
  late bool isRunning;

  Stream<List<Widget>> getText() async* {
    while (isRunning) {
      List<(int, String, double)> processes = await getAllProcesses();
      List<Widget> widgets = [];
      for (int i = 0; i < processes.length; i++) {
        widgets.add(
          ListTile(
            leading: Text("PID : ${processes[i].$1}"),
            subtitle: Text(processes[i].$2),
            trailing: Text("Usage: ${processes[i].$3}%"),
          ),
        );
      }
      yield widgets;
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }

  @override
  void initState() {
    isRunning = true;
    super.initState();
  }

  @override
  void dispose() {
    isRunning = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Widget>>(
      stream: getText(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("Es hat einen Fehler gegeben!");
        }
        final items = snapshot.data ?? <Widget>[];
        return Expanded(child: ListView(children: items));
      },
    );
  }
}
