import 'package:flutter/material.dart';

class BuildTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String firstColumnTitle;
  final String secondColumnTitle;

  const BuildTable({
    Key? key,
    required this.data,
    required this.firstColumnTitle,
    required this.secondColumnTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.black26),
        ),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
        },
        children: [
          // Table Header
          TableRow(
            decoration: BoxDecoration(color: Colors.green.shade100),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  firstColumnTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  secondColumnTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // Table Data
          ...data.map(
            (row) => TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    row[firstColumnTitle] ?? '',
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    row[secondColumnTitle] ?? '',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
