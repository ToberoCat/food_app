import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_app/username_gate.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LunchApp());
}

class LunchApp extends StatelessWidget {
  const LunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Lunch',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const UsernameGate(),
    );
  }
}

final db = FirebaseFirestore.instance;

DateTime _startOfToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Stream<QuerySnapshot<Map<String, dynamic>>> foods() =>
    db.collection('foods').snapshots();

Future<void> addFood(String name, double basePrice) =>
    db.collection('foods').add({'name': name, 'price': basePrice});

Future<void> deleteFood(String id) => db.collection('foods').doc(id).delete();

// --- BALANCES ---
Future<double> balanceOf(String username) async {
  final snap = await db.collection('balances').doc(username).get();
  return (snap.data()?['credit'] ?? 0).toDouble();
}

Future<void> addCredit(String username, double amount) => db
    .collection('balances')
    .doc(username)
    .set({'credit': FieldValue.increment(amount)}, SetOptions(merge: true));

// --- DRINK BALANCES ---
Future<double> drinkBalanceOf(String username) async {
  final snap = await db.collection('drink_balances').doc(username).get();
  return (snap.data()?['credit'] ?? 0).toDouble();
}

Future<void> addDrinkCredit(String username, double amount) => db
    .collection('drink_balances')
    .doc(username)
    .set({'credit': FieldValue.increment(amount)}, SetOptions(merge: true));

Stream<QuerySnapshot<Map<String, dynamic>>> todaysOrders() {
  final ts = Timestamp.fromDate(_startOfToday());
  return db
      .collection('orders')
      .where('ts', isGreaterThanOrEqualTo: ts)
      .orderBy('ts')
      .snapshots();
}

Future<void> removeOrder(String id) => db.collection('orders').doc(id).delete();

Future<void> updateFood(String id, String name, double price) =>
    db.collection('foods').doc(id).update({'name': name, 'price': price});

// --- DEBTS ---------------------------------------------------------------
/// Increase (positive) or decrease (negative) the debtor → creditor balance.
Future<void> addDebt({
  required String debtor,
  required String creditor,
  required double amount,
}) async {
  // Look for an existing pair-document first:
  final snap = await db
      .collection('debts')
      .where('debtor', isEqualTo: debtor)
      .where('creditor', isEqualTo: creditor)
      .limit(1)
      .get();

  if (snap.docs.isEmpty) {
    await db.collection('debts').add({
      'debtor': debtor,
      'creditor': creditor,
      'amount': amount,
    });
  } else {
    await db
        .collection('debts')
        .doc(snap.docs.first.id)
        .update({'amount': FieldValue.increment(amount)});
  }
}

/// Stream of every debt doc – used by DebtsTab
Stream<QuerySnapshot<Map<String, dynamic>>> debts() =>
    db.collection('debts').snapshots();


// --- ORDERS ---
Future<void> addOrder({
  required String username,
  required String foodId,
  required String foodName,
  required double price,
  required String notes,
}) async {
  double credit = await balanceOf(username);
  if (credit >= price) {
    // auto-debit
    await db.collection('balances').doc(username).update({
      'credit': FieldValue.increment(-price),
    });
  }
  await db.collection('orders').add({
    'user': username,
    'foodId': foodId,
    'foodName': foodName,
    'price': price,
    'notes': notes,
    'ts': FieldValue.serverTimestamp(),
  });
}
