import 'package:flutter/material.dart';
import 'package:system_breakdown/src/rust/api/process.dart';

class CRow extends StatelessWidget {
  final Process proc;
  const CRow(this.proc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text("${proc.pid}"),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(proc.name),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "${(proc.memory.toDouble() / 1048576).toStringAsFixed(2)} MB",
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text("${proc.usage.toStringAsFixed(2)}%"),
          ),
        ),
      ],
    );
  }
}
