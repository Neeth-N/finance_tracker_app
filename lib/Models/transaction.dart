import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String id;
  String description;
  double amount;
  DateTime date;

  Transaction({required this.id, required this.description, required this.amount, required this.date});

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Transaction(
      id: doc.id,
      description: data['description'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'date': date,
    };
  }
}