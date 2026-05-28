import 'package:flutter/material.dart';
import 'header_cell.dart';

class Header extends StatelessWidget {
  final int sortColIndex;
  final Function(int, bool) onSort;
  final bool sortAsc;
  const Header(this.sortColIndex, this.sortAsc, this.onSort, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          HeaderCell("PID", 0, 1, sortColIndex, sortAsc, onSort),
          HeaderCell("Name", 1, 3, sortColIndex, sortAsc, onSort),
          HeaderCell("Speicher", 2, 2, sortColIndex, sortAsc, onSort),
          HeaderCell("CPU", 3, 2, sortColIndex, sortAsc, onSort),
        ],
      ),
    );
  }
}
