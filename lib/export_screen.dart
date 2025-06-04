import 'package:flutter/material.dart';

import 'main.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Orders")),
      body: StreamBuilder(
        stream: todaysOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No orders today'));
          }

          final Map<String, _Summary> grouped = {};
          for (var d in docs) {
            final data = d.data();
            final name = data['foodName'] as String;
            final notes = (data['notes'] as String?) ?? '';
            final price = (data['price'] as num).toDouble();
            final key = '$name||$notes';
            grouped.putIfAbsent(key, () => _Summary(name, notes, price)).count++;
          }

          final rows = grouped.values.map((s) {
            final total = s.count * s.price;
            return DataRow(cells: [
              DataCell(Text(s.name)),
              DataCell(Text(s.notes.isEmpty ? '-' : s.notes)),
              DataCell(Text('${s.count}')),
              DataCell(Text('€${total.toStringAsFixed(2)}')),
            ]);
          }).toList();

          final totalSum = grouped.values
              .fold<double>(0, (p, e) => p + (e.price * e.count));

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Variant')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Total')),
                    ],
                    rows: rows,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Grand total: €${totalSum.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Summary {
  final String name;
  final String notes;
  final double price;
  int count;

  _Summary(this.name, this.notes, this.price) : count = 0;
}
