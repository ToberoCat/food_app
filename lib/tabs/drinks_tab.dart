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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadBalance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance Card
              Card(
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade100,
                        Colors.cyan.shade100,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_drink,
                        size: 48,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Drink Balance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '€${_balance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _balance >= 0 ? Colors.blue.shade700 : Colors.red,
                        ),
                      ),
                      if (_balance < 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Low Balance',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Add Money Section
              _buildTransactionSection(
                context,
                title: 'Add Money',
                icon: Icons.add_circle_outline,
                color: Colors.green,
                controller: _addController,
                onPressed: _addMoney,
                buttonText: 'Add Money',
                hintText: 'Enter amount to add',
              ),
              const SizedBox(height: 24),

              // Quick Payment Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.local_drink, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Pay for Drink',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtractController,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                hintText: 'Default: €1.50',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.euro),
                                suffixText: '€',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _subtractMoney(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _subtractMoney,
                            icon: const Icon(Icons.local_drink),
                            label: const Text('Pay'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
    required VoidCallback onPressed,
    required String buttonText,
    required String hintText,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.euro),
                suffixText: '€',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onPressed(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(buttonText),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
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
