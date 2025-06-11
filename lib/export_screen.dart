import 'package:flutter/material.dart';

import 'main.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _byVariant = false;
  final Map<String, Color> _variantColors = {};

  Color _colorForVariant(String variant) {
    return _variantColors.putIfAbsent(
      variant,
      () => Colors
          .primaries[_variantColors.length % Colors.primaries.length]
          .shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Orders"),
        actions: [
          IconButton(
            icon: Icon(_byVariant ? Icons.table_view : Icons.palette),
            tooltip: _byVariant ? 'View by product' : 'Group by variant',
            onPressed: () => setState(() => _byVariant = !_byVariant),
          ),
        ],
      ),
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

          if (_byVariant) {
            final Map<String, List<Map<String, dynamic>>> byVariant = {};
            for (var d in docs) {
              final data = d.data();
              final variant = (data['notes'] as String?) ?? '';
              byVariant.putIfAbsent(variant, () => []).add(data);
            }

            final children = <Widget>[];
            byVariant.forEach((variant, orders) {
              final rows = orders.map((o) {
                return DataRow(
                  color: MaterialStateProperty.all(_colorForVariant(variant)),
                  cells: [
                    DataCell(Text(o['foodName'] as String)),
                    DataCell(Text(o['user'] as String)),
                    DataCell(Text((o['notes'] as String?)?.isEmpty ?? true
                        ? '-'
                        : o['notes'] as String)),
                  ],
                );
              }).toList();

              children.addAll([
                Container(
                  width: double.infinity,
                  color: _colorForVariant(variant),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    variant.isEmpty ? '-' : variant,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Food')),
                      DataColumn(label: Text('User')),
                      DataColumn(label: Text('Variant')),
                    ],
                    rows: rows,
                  ),
                ),
                const SizedBox(height: 16),
              ]);
            });

            return ListView(children: children);
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
