import 'package:flutter/material.dart';
import 'package:system_breakdown/src/features/cpu/presentation/cpu.dart';
import 'package:system_breakdown/src/features/processes/presentation/processes.dart';
import 'package:system_breakdown/src/features/ram/presentation/ram.dart';

// ignore: must_be_immutable
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late Widget currentPage;
  late String currentPageName;

  @override
  void initState() {
    currentPage = ProcessesPage();
    currentPageName = "Processes";
    super.initState();
  }

  void onProcessesTap() {
    currentPage = ProcessesPage();
    currentPageName = "Processes";
    setState(() {});
  }

  void onCPUTap() {
    currentPage = CPUPage();
    currentPageName = "CPU";
    setState(() {});
  }

  void onRAMTap() {
    currentPage = RAMPage();
    currentPageName = "RAM";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("System Breakdown")),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 150,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(onPressed: onCPUTap, child: Text("CPU")),
                  TextButton(onPressed: onRAMTap, child: Text("RAM")),
                  TextButton(
                    onPressed: onProcessesTap,
                    child: Text("Processes"),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey.shade300),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    currentPageName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Divider(color: Colors.grey.shade400, height: 1),
                  ),
                  Expanded(child: currentPage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
