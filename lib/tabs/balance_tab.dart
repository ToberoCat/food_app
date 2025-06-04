import 'package:flutter/material.dart';

import '../main.dart';

class BalanceTab extends StatefulWidget {
  final String username;

  const BalanceTab({required this.username, super.key});

  @override
  State<BalanceTab> createState() => _BalanceTabState();
}

class _BalanceTabState extends State<BalanceTab> {
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _subtractController = TextEditingController();
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await balanceOf(widget.username);
    setState(() {
      _balance = balance;
    });
  }

  Future<void> _addMoney() async {
    final amount = double.tryParse(_addController.text.replaceAll(',', '.'));
    if (amount != null && amount > 0) {
      await addCredit(widget.username, amount);
      _addController.clear();
      await _loadBalance();
    }
  }

  Future<void> _subtractMoney() async {
    final amount = double.tryParse(_subtractController.text.replaceAll(',', '.'));
    if (amount != null && amount > 0) {
      await addCredit(widget.username, -amount);
      _subtractController.clear();
      await _loadBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
          Text('Deposit', style: Theme.of(context).textTheme.titleMedium),
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
          Text('Withdraw', style: Theme.of(context).textTheme.titleMedium),
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
                child: const Text('Withdraw'),
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
