import 'package:flutter/material.dart';
import 'package:system_breakdown/src/features/processes/domain/crow.dart';
import 'package:system_breakdown/src/features/processes/domain/header.dart';
import 'package:system_breakdown/src/rust/api/process.dart';

class ProcessesPage extends StatefulWidget {
  const ProcessesPage({super.key});

  @override
  State<ProcessesPage> createState() => _ProcessesPageState();
}

class _ProcessesPageState extends State<ProcessesPage> {
  late Future<Processes> processesFuture;
  late Stream<List<Process>> processesStream;
  bool isRunning = false;
  List<Process> cachedRaw = [];
  List<Process> cachedSorted = [];

  int _sortColIndex = 0;
  bool _sortAsc = false;

  Stream<List<Process>> getProcessesStream() async* {
    Processes processes = await processesFuture;
    while (isRunning) {
      List<Process> procs = await processes.getAllProcesses();
      yield procs;
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }

  List<Process> _sorted(List<Process> procs) {
    if (!identical(procs, cachedRaw)) {
      cachedRaw = procs;
      cachedSorted = [...procs];
      cachedSorted.sort((a, b) {
        return _compare(a, b);
      });
    }
    return cachedSorted;
  }

  int _compare(Process a, Process b) {
    int cmp;
    switch (_sortColIndex) {
      case 0:
        cmp = a.pid.compareTo(b.pid);
        break;
      case 1:
        cmp = a.name.compareTo(b.name);
        break;
      case 2:
        cmp = a.memory.compareTo(b.memory);
        break;
      case 3:
        cmp = a.usage.compareTo(b.usage);
        break;
      default:
        return 0;
    }
    return _sortAsc ? cmp : -cmp;
  }

  void _onSort(int col, bool asc) {
    setState(() {
      _sortColIndex = col;
      _sortAsc = asc;
      cachedSorted.sort((a, b) => _compare(a, b));
    });
  }

  @override
  void initState() {
    super.initState();
    isRunning = true;
    processesFuture = Processes.newInstance();
    processesStream = getProcessesStream();
  }

  @override
  void dispose() {
    isRunning = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: processesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            "Fehler: ${snapshot.error}",
            style: TextStyle(color: Colors.red),
          );
        }
        if (snapshot.hasData) {
          List<Process> procs = _sorted(snapshot.data!);
          return Column(
            children: [
              Header(_sortColIndex, _sortAsc, _onSort),

              Expanded(
                child: ListView.builder(
                  itemCount: procs.length,
                  itemExtent: 40,
                  itemBuilder: (context, index) => CRow(procs[index]),
                ),
              ),
            ],
          );
        }
        return Text("etwas ist schief gegangen.");
      },
    );
  }
}
