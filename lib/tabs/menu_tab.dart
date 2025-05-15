import 'package:flutter/material.dart';

import '../main.dart';

class MenuTab extends StatefulWidget {
  final String username;

  const MenuTab({required this.username, super.key});

  @override
  _MenuTabState createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: foods(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final name = data['name'] as String;
                final price = (data['price'] as num).toDouble();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '€${price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () => _showFoodDialog(
                            context,
                            doc.id,
                            initialName: name,
                            initialPrice: price,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete',
                          onPressed: () => deleteFood(doc.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFoodDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFoodDialog(
    BuildContext context,
    String? id, {
    String initialName = '',
    double initialPrice = 0,
  }) {
    final nameCtrl = TextEditingController(text: initialName);
    final priceCtrl = TextEditingController(
      text: initialPrice != 0 ? initialPrice.toString() : '',
    );
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(id == null ? 'Add Food' : 'Edit Food'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final n = nameCtrl.text.trim();
                  final p = double.tryParse(priceCtrl.text) ?? 0;
                  if (n.isNotEmpty) {
                    if (id == null) {
                      await addFood(n, p);
                    } else {
                      await updateFood(id, n, p);
                    }
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}

