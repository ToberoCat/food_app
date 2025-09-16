import 'package:flutter/material.dart';
import 'package:food_app/tabs/totals_tab.dart';
import 'package:food_app/tabs/drinks_tab.dart';
import 'package:food_app/tabs/balance_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'export_screen.dart';

import 'tabs/menu_tab.dart';
import 'tabs/order_tab.dart';
import 'username_gate.dart';

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
      DrinksTab(username: widget.username),
      BalanceTab(username: widget.username),
    ];
    final titles = [
      'Menu',
      'Place Order',
      'Totals',
      'Drinks',
      'Orders',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              _getIconForIndex(_index),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              titles[_index],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          if (_index == 2)
            IconButton(
              icon: const Icon(Icons.table_view),
              tooltip: 'Export Data',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExportScreen(),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: pages[_index],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Totals',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_drink_outlined),
              selectedIcon: Icon(Icons.local_drink),
              label: 'Drinks',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    const icons = [
      Icons.restaurant_menu,
      Icons.shopping_cart,
      Icons.analytics,
      Icons.local_drink,
      Icons.receipt_long,
    ];
    return icons[index];
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove('username');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UsernameGate()),
          (route) => false,
        );
      }
    }
  }
}
