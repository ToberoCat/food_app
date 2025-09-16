import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class BalanceTab extends StatefulWidget {
  final String username;

  const BalanceTab({required this.username, super.key});

  @override
  State<BalanceTab> createState() => _BalanceTabState();
}

class _BalanceTabState extends State<BalanceTab> {
  Set<String> _settledOrders = {};

  Future<void> _markAsSettled(String orderId) async {
    setState(() {
      _settledOrders.add(orderId);
    });
  }

  Future<void> _markAsUnsettled(String orderId) async {
    setState(() {
      _settledOrders.remove(orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: todaysOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders today',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs
              .where((doc) => doc['user'] == widget.username)
              .toList();

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders for you today',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final totalAmount = orders.fold<double>(
            0.0,
            (sum, doc) => sum + (doc['price'] as num).toDouble(),
          );

          final settledCount = orders.where((doc) => _settledOrders.contains(doc.id)).length;
          final allSettled = settledCount == orders.length;

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: allSettled
                          ? [Colors.green.shade100, Colors.green.shade200]
                          : [Colors.orange.shade100, Colors.orange.shade200],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        allSettled ? Icons.check_circle : Icons.receipt_long,
                        size: 40,
                        color: allSettled ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        allSettled ? 'All Settled!' : "Today's Orders",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: allSettled ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€${totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: allSettled ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$settledCount of ${orders.length} orders settled',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: allSettled ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final orderId = order.id;
                      final isSettled = _settledOrders.contains(orderId);
                      final timestamp = (order['ts'] as Timestamp).toDate();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSettled ? Colors.green : Colors.orange,
                            child: Icon(
                              isSettled ? Icons.check : Icons.receipt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            order['foodName'],
                            style: TextStyle(
                              decoration: isSettled ? TextDecoration.lineThrough : null,
                              color: isSettled ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Text(
                            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: isSettled ? Colors.grey : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '€${(order['price'] as num).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: isSettled ? TextDecoration.lineThrough : null,
                                  color: isSettled ? Colors.grey : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  if (isSettled) {
                                    _markAsUnsettled(orderId);
                                  } else {
                                    _markAsSettled(orderId);
                                  }
                                },
                                icon: Icon(
                                  isSettled ? Icons.undo : Icons.check_circle_outline,
                                  color: isSettled ? Colors.grey : Colors.green,
                                ),
                                tooltip: isSettled ? 'Mark as unsettled' : 'Mark as settled',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
