// ignore: file_names
import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  const CustomTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Table(
          border: TableBorder.all(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: const [
            TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text('1'),
                ),
              ],
            ),
          ]),
    ));
  }
}

class CustomTableRow extends StatelessWidget {
  final int index;

  const CustomTableRow({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    if (index == 3) {
      // Special row with multiple cells
      return const TableRowWithMultipleCells(
        cell1: 'Cell 4',
        cell2: 'Cell 5',
        cell3: 'Cell 6',
      );
    } else {
      // Default row with a single cell
      return TableRowWithSingleCell(cellContent: 'Cell ${index + 1}');
    }
  }
}

class TableRowWithSingleCell extends StatelessWidget {
  final String cellContent;

  const TableRowWithSingleCell({super.key, required this.cellContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(cellContent),
      ),
    );
  }
}

class TableRowWithMultipleCells extends StatelessWidget {
  final String cell1;
  final String cell2;
  final String cell3;

  const TableRowWithMultipleCells({
    super.key,
    required this.cell1,
    required this.cell2,
    required this.cell3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RowWithDivider(
          child: CustomCell(content: cell1),
        ),
        RowWithDivider(
          child: CustomCell(content: cell2),
        ),
        RowWithDivider(
          child: CustomCell(content: cell3),
        ),
      ],
    );
  }
}

class CustomCell extends StatelessWidget {
  final String content;

  const CustomCell({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content),
    );
  }
}

class RowWithDivider extends StatelessWidget {
  final Widget child;

  const RowWithDivider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(),
        ),
        Expanded(
          flex: 4,
          child: child,
        ),
        const Expanded(
          child: Divider(),
        ),
      ],
    );
  }
}
