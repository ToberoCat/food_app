import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_app/main.dart';

///**********************************************
/// OrdersTab – swipe-to-delete + notes display
///**********************************************
class OrdersTab extends StatefulWidget {
  final String username;

  const OrdersTab({required this.username, super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: todaysOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!.docs;
          if (orders.isEmpty) return const Center(child: Text('No orders today'));
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final doc = orders[i];
              final data = doc.data();
              final self = data['user'] == widget.username;
              return Slidable(
                // ← swipe row
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        if (self) await removeOrder(doc.id);
                      },
                      icon: Icons.delete,
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    '${data['foodName']} – €${data['price'].toStringAsFixed(2)}',
                  ),
                  subtitle: Text(data['notes']), // ← notes visible
                  trailing: Text(data['user']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOrderDialog,
        child: const Icon(Icons.add),
        tooltip: 'Place Order',
      ),
    );
  }

  void _showOrderDialog() {
    String? selectedFoodId;
    String? selectedFoodName;
    double? selectedPrice;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Place Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder(
                  stream: foods(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final foodItems = snapshot.data!.docs;
                    if (foodItems.isEmpty) {
                      return const Text('No food items available');
                    }

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Food'),
                      items: foodItems.map((doc) {
                        final data = doc.data();
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: SizedBox(
                            width: 200,
                            child: Text(
                              '${data['name']} - €${data['price'].toStringAsFixed(2)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () {
                            selectedFoodName = data['name'];
                            selectedPrice = data['price'].toDouble();
                          },
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedFoodId = value;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Any special requests?',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedFoodId != null && selectedFoodName != null && selectedPrice != null) {
                  await addOrder(
                    username: widget.username,
                    foodId: selectedFoodId!,
                    foodName: selectedFoodName!,
                    price: selectedPrice!,
                    notes: notesController.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a food item')),
                  );
                }
              },
              child: const Text('ORDER'),
            ),
          ],
        );
      },
    );
  }
}
