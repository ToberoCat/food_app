import 'package:flutter/material.dart';
import 'package:food_app/main.dart';

///**********************************************
/// TotalsTab – kitchen view (unchanged except today-filter)
///**********************************************
class TotalsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: todaysOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        final Map<String, int> counts = {};
        final Map<String, double> sumPrices = {};
        for (var d in docs) {
          final name = d['foodName'];
          counts[name] = (counts[name] ?? 0) + 1;
          sumPrices[name] =
              (sumPrices[name] ?? 0) + (d['price'] as num).toDouble();
        }
        final total = sumPrices.values.fold<double>(0, (p, e) => p + e);
        return Column(
          children: [
            Expanded(
              child: ListView(
                children:
                counts.entries
                    .map(
                      (e) => ListTile(
                    title: Text(e.key),
                    trailing: Text(
                      '${e.value} × (€${sumPrices[e.key]!.toStringAsFixed(2)})',
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
            ListTile(
              title: const Text('Grand total'),
              trailing: Text(
                '€${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}