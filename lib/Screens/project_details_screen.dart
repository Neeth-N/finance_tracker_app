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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(project.name)),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          showSelectedLabels:false,
          showUnselectedLabels: false,
          selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 3,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_graph_outlined),
                label: 'Graph'
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
                    borderRadius: BorderRadius.circular(25),
                    boxShadow:[
                      BoxShadow(
                        blurRadius: 2,
                        color: Colors.grey.shade400,
                        offset: Offset(3,4)
                    )
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Current Amount', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),),
                      Text('₹${updatedProject.currentAmount.toString()}',style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.arrow_downward_outlined, size: 18, color: Colors.greenAccent),
                                  ),
                                ),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Incomes', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400),),
                                    Text('₹${updatedProject.incAmount.toString()}',style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                      color: Colors.white30,
                                      shape: BoxShape.circle
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.arrow_upward_outlined, size: 18, color: Colors.red),
                                  ),
                                ),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Expenses', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400),),
                                    Text('₹${updatedProject.decAmount.toString()}',style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  )
              ),
              SizedBox(height: 12,),
              Text('Transactions', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),),
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
                        return Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            // height: 75,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: ListTile(
                              title: Text(transaction.description),
                              subtitle: Text('Amount: ₹${transaction.amount.toString()}'),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditTransactionDialog(context, transaction, updatedProject),
                              ),
                            ),
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
            child: const Icon(Icons.add, color: Colors.white, size: 30),
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
                if(amount<0){
                  projectDoc.update({
                    'decAmount': firestore.FieldValue.increment(amount),
                  });
                }else{
                  projectDoc.update({
                    'incAmount': firestore.FieldValue.increment(amount),
                  });
                }
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
                if(amount<0){
                  projectDoc.update({
                    'decAmount': firestore.FieldValue.increment(amountDifference),
                  });
                }else{
                  projectDoc.update({
                    'incAmount': firestore.FieldValue.increment(amountDifference),
                  });
                }
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
