import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  String id;
  String name;
  double initialAmount;
  double currentAmount;
  double incAmount;
  double decAmount;

  Project({required this.id, required this.name, required this.initialAmount, required this.currentAmount, required this.decAmount, required this.incAmount});

  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      initialAmount: data['initialAmount']?.toDouble() ?? 0.0,
      currentAmount: data['currentAmount']?.toDouble() ?? 0.0,
      incAmount: data['incAmount']?.toDouble() ?? 0.0,
      decAmount: data['decAmount']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'initialAmount': initialAmount,
      'currentAmount': currentAmount,
      'incAmount' : incAmount,
      'decAmount' : decAmount
    };
  }
}
