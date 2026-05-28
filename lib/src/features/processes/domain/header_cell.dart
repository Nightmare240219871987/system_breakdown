import 'package:flutter/material.dart';

class HeaderCell extends StatelessWidget {
  final String label;
  final int colIndex;
  final int flex;
  final int sortColIndex;
  final bool sortAsc;
  final Function(int, bool) onSort;
  const HeaderCell(
    this.label,
    this.colIndex,
    this.flex,
    this.sortColIndex,
    this.sortAsc,
    this.onSort, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = sortColIndex == colIndex;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => onSort(colIndex, isActive ? !sortAsc : true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              if (isActive) ...[
                const SizedBox(width: 4),
                Icon(
                  sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
