import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Table(
          border: TableBorder.all(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(
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

  CustomTableRow({required this.index});

  @override
  Widget build(BuildContext context) {
    if (index == 3) {
      // Special row with multiple cells
      return TableRowWithMultipleCells(
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

  const TableRowWithSingleCell({required this.cellContent});

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

  RowWithDivider({required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(),
        ),
        Expanded(
          flex: 4,
          child: child,
        ),
        Expanded(
          child: Divider(),
        ),
      ],
    );
  }
}
