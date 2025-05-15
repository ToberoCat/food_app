import 'package:flutter/material.dart';
import 'package:food_app/main.dart';

class DrinksTab extends StatefulWidget {
  final String username;

  const DrinksTab({required this.username, super.key});

  @override
  State<DrinksTab> createState() => _DrinksTabState();
}

class _DrinksTabState extends State<DrinksTab> {
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _subtractController = TextEditingController(text: '1.50');
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    // Use drinkBalanceOf instead of balanceOf
    final balance = await drinkBalanceOf(widget.username);
    setState(() {
      _balance = balance;
    });
  }

  Future<void> _addMoney() async {
    final amount = double.tryParse(_addController.text);
    if (amount != null && amount > 0) {
      // Use addDrinkCredit instead of addCredit
      await addDrinkCredit(widget.username, amount);
      _addController.clear();
      await _loadBalance();
    }
  }

  Future<void> _subtractMoney() async {
    final amount = double.tryParse(_subtractController.text);
    if (amount != null && amount > 0) {
      // Use addDrinkCredit instead of addCredit
      await addDrinkCredit(widget.username, -amount); // Subtract by adding negative amount
      setState(() {
        _subtractController.text = '1.50'; // Reset to default
      });
      await _loadBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance display
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Current Balance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_balance.toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _balance >= 0 ? Colors.green : Colors.red,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Add money section
          Text(
            'Add Money',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (€)',
                    suffixText: '€',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addMoney,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Subtract money section
          Text(
            'Pay for Drink',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtractController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (€)',
                    suffixText: '€',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _subtractMoney,
                child: const Text('Pay'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _addController.dispose();
    _subtractController.dispose();
    super.dispose();
  }
}
