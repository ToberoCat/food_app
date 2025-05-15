import 'package:flutter/material.dart';

import '../main.dart';

///**********************************************
/// DebtsTab – show per-user spendings, credit and debt
/// Now with inline *Add Credit* support.
///**********************************************
class DebtsTab extends StatefulWidget {
  const DebtsTab({super.key});

  @override
  State<DebtsTab> createState() => _DebtsTabState();
}

class _DebtsTabState extends State<DebtsTab> {
  /// Fetches current credit for a set of users (single round-trip).
  Future<Map<String, double>> _fetchBalances(Iterable<String> users) async {
    final snaps = await Future.wait(
      users.map((u) => db.collection('balances').doc(u).get()),
    );
    final Map<String, double> credits = {};
    for (var s in snaps) {
      credits[s.id] = (s.data()?['credit'] ?? 0).toDouble();
    }
    return credits;
  }

  /// Opens a dialog that lets the operator top-up *[user]* by an arbitrary amount.
  void _showAddCreditDialog(String user) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add credit for $user'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount (€)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final raw = controller.text.replaceAll(',', '.');
                final amount = double.tryParse(raw);
                if (amount == null || amount == 0) return; // ignore bad input

                await addCredit(user, amount);
                if (context.mounted) Navigator.of(context).pop();
                // Force rebuild so the FutureBuilder refetches balances
                setState(() {});
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: todaysOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No orders today'));
        }

        // Calculate per-user total spendings for today.
        final Map<String, double> userTotals = {};
        for (var d in docs) {
          final String user = d['user'];
          userTotals[user] =
              (userTotals[user] ?? 0) + (d['price'] as num).toDouble();
        }

        return FutureBuilder<Map<String, double>>(
          future: _fetchBalances(userTotals.keys),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final credits = snap.data!;
            // inside the FutureBuilder where you map over userTotals.entries ⬇
            return ListView(
              children:
                  userTotals.entries.map((entry) {
                    final user = entry.key;
                    final spent = entry.value;
                    final credit = credits[user] ?? 0.0;

                    // net balance after today’s purchases
                    final net = credit - spent;

                    return ListTile(
                      title: Text(user),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '€${net.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: net < 0 ? Colors.red : Colors.green,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: 'Add credit',
                            onPressed: () => _showAddCreditDialog(user),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            );
          },
        );
      },
    );
  }
}
