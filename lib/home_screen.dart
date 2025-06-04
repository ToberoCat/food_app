import 'package:flutter/material.dart';
import 'package:food_app/tabs/totals_tab.dart';
import 'package:food_app/tabs/drinks_tab.dart';
import 'package:food_app/tabs/balance_tab.dart';
import 'export_screen.dart';

import 'tabs/debt_tab.dart';
import 'tabs/menu_tab.dart';
import 'tabs/order_tab.dart';

///**********************************************
/// Home
///**********************************************
class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({required this.username, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      MenuTab(username: widget.username),
      OrdersTab(username: widget.username),
      TotalsTab(),
      DebtsTab(),
      DrinksTab(username: widget.username),
      BalanceTab(username: widget.username),
    ];
    final titles = [
      'Menu',
      'Place Order',
      'Totals',
      'Debts',
      'Drinks',
      'Balance',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: _index == 2
            ? [
                IconButton(
                  icon: const Icon(Icons.table_view),
                  tooltip: 'Export',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExportScreen(),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Totals'),
          NavigationDestination(icon: Icon(Icons.money_off), label: 'Debts'),
          NavigationDestination(icon: Icon(Icons.local_drink), label: 'Drinks'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Balance'),
        ],
      ),
    );
  }
}
