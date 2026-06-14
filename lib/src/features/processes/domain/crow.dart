import 'package:flutter/material.dart';
import 'package:system_breakdown/src/rust/api/process.dart';

class CRow extends StatelessWidget {
  final Process proc;
  final void Function(int)? onKill;
  const CRow(this.proc, {super.key, this.onKill});

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
              "${(proc.memory.toDouble() / 1048576).toStringAsFixed(2)} MiB",
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
        Expanded(
          flex: 2,
          child: Row(
            children: [
              IconButton(
                onPressed: onPressed,
                icon: Icon(Icons.cancel_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onPressed() {
    if (onKill != null) {
      onKill!(proc.pid);
    }
  }
}
