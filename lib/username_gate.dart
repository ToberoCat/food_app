import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'main.dart';

///**********************************************
/// Username gate – local nickname, no auth
///**********************************************
class UsernameGate extends StatefulWidget {
  const UsernameGate({super.key});

  @override
  State<UsernameGate> createState() => _UsernameGateState();
}

class _UsernameGateState extends State<UsernameGate> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final name = sp.getString('username');
    if (name != null && name.isNotEmpty) {
      _gotoHome(name);
    } else {
      setState(() => _loading = false);
    }
  }

  void _gotoHome(String username) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Enter nickname')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final name = _controller.text.trim();
                if (name.isEmpty) return;
                final sp = await SharedPreferences.getInstance();
                await sp.setString('username', name);
                _gotoHome(name);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
