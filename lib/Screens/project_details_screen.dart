import 'dart:math';

import 'package:flutter/material.dart';
import '../Models/project.dart';
import '../Models/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;

  ProjectDetailsScreen({required this.project});

  @override
  Widget build(BuildContext context) {
    final firestore.DocumentReference projectDoc = firestore.FirebaseFirestore.instance.collection('projects').doc(project.id);

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          backgroundColor: Colors.grey.shade300,
          showSelectedLabels:false,
          showUnselectedLabels: false,
          elevation: 3,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings'
            )
          ],
        ),
      ),
      body: StreamBuilder<firestore.DocumentSnapshot>(
        stream: projectDoc.snapshots(),
        builder: (context, projectSnapshot) {
          if (!projectSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final updatedProject = Project.fromFirestore(projectSnapshot.data!);

          return Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width-20,
                  height: MediaQuery.of(context).size.width/2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE064F7),
                        Color(0xFF00B2E7)
                      ],
                      transform: GradientRotation(pi/4)
                    ),
                    borderRadius: BorderRadius.circular(25)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Current Amount', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),),
                      Text('₹${updatedProject.currentAmount.toString()}',style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  )
              ),
              Expanded(
                child: StreamBuilder<firestore.QuerySnapshot>(
                  stream: firestore.FirebaseFirestore.instance
                      .collection('transactions')
                      .where('projectId', isEqualTo: project.id)
                      .snapshots(),
                  builder: (context, transactionSnapshot) {
                    if (!transactionSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var transactions = transactionSnapshot.data!.docs.map((doc) => Transaction.fromFirestore(doc)).toList();

                    return ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        var transaction = transactions[index];
                        return ListTile(
                          title: Text(transaction.description),
                          subtitle: Text('Amount: ₹${transaction.amount.toString()}'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditTransactionDialog(context, transaction, updatedProject),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => _showAddTransactionDialog(context, projectDoc),
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE064F7),
                    Color(0xFF00B2E7)
                  ],
                  transform: GradientRotation(pi/4)
              ),
            ),
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, firestore.DocumentReference projectDoc) {
    String description = '';
    double amount = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = double.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (description.isNotEmpty && amount != 0) {
                firestore.FirebaseFirestore.instance.collection('transactions').add({
                  'description': description,
                  'amount': amount,
                  'date': firestore.Timestamp.now(),
                  'projectId': projectDoc.id,
                });
                projectDoc.update({
                  'currentAmount': firestore.FieldValue.increment(amount),
                });
                Navigator.pop(context);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditTransactionDialog(BuildContext context, Transaction transaction, Project updatedProject) {
    String description = transaction.description;
    double amount = transaction.amount;
    final firestore.DocumentReference projectDoc = firestore.FirebaseFirestore.instance.collection('projects').doc(updatedProject.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
              controller: TextEditingController(text: transaction.description),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = double.tryParse(value) ?? transaction.amount,
              controller: TextEditingController(text: transaction.amount.toString()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (description.isNotEmpty && amount != 0) {
                double amountDifference = amount - transaction.amount;
                firestore.FirebaseFirestore.instance.collection('transactions').doc(transaction.id).update({
                  'description': description,
                  'amount': amount,
                });
                projectDoc.update({
                  'currentAmount': firestore.FieldValue.increment(amountDifference),
                });
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
