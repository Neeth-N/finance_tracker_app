import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Models/project.dart';
import '../Models/transaction.dart';
import 'chart_screen.dart';


class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _showCurrentAmount = true;

  @override
  Widget build(BuildContext context) {
    final firestore.DocumentReference projectDoc = firestore.FirebaseFirestore.instance.collection('projects').doc(widget.project.id);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(widget.project.name, style: GoogleFonts.chivo(fontWeight: FontWeight.bold),)),
      body:buildStreamBuilder(projectDoc),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAddTransactionButton(context, projectDoc),
    );
  }

  StreamBuilder<firestore.DocumentSnapshot<Object?>> buildStreamBuilder(firestore.DocumentReference<Object?> projectDoc) {
    return StreamBuilder<firestore.DocumentSnapshot>(
      stream: projectDoc.snapshots(),
      builder: (context, projectSnapshot) {
        if (!projectSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (projectSnapshot.hasError) {
          return Center(child: Text('Error: ${projectSnapshot.error}'));
        }

        final updatedProject = Project.fromFirestore(projectSnapshot.data!);

        return Column(
          children: [
            _buildProjectSummary(context, updatedProject),
            const SizedBox(height: 12),
            _buildTransactionListHeader(context),
            Expanded(
              child: StreamBuilder<firestore.QuerySnapshot>(
                stream: firestore.FirebaseFirestore.instance
                    .collection('transactions')
                    .where('projectId', isEqualTo: widget.project.id)
                    .snapshots(),
                builder: (context, transactionSnapshot) {
                  if (!transactionSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (transactionSnapshot.hasError) {
                    return Center(child: Text('Error: ${transactionSnapshot.error}'));
                  }

                  var transactions = transactionSnapshot.data!.docs.map((doc) => Transaction.fromFirestore(doc)).toList();

                  return _buildTransactionList(context, transactions, updatedProject);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectSummary(BuildContext context, Project updatedProject) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      height: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE064F7),
            Color(0xFF00B2E7),
          ],
          transform: GradientRotation(pi / 4),
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.grey.shade400,
            offset: const Offset(3, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onDoubleTap: () {
          setState(() {
            _showCurrentAmount = !_showCurrentAmount;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              //'Current Amount',
              _showCurrentAmount ? 'Current Amount' : 'Initial Amount',
              //style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600,),
              style: GoogleFonts.chivo(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
            ),
            Text(
              '₹${_showCurrentAmount ? updatedProject.currentAmount : updatedProject.initialAmount}',
              //style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold,),
              style: GoogleFonts.chivo(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildIncomeExpenseRow(context, updatedProject),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseRow(BuildContext context, Project updatedProject) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIncomeExpenseItem(
            context,
            icon: Icons.arrow_downward_outlined,
            iconColor: Colors.greenAccent,
            title: 'Incomes',
            amount: updatedProject.incAmount,
          ),
          _buildIncomeExpenseItem(
            context,
            icon: Icons.arrow_upward_outlined,
            iconColor: Colors.red,
            title: 'Expenses',
            amount: -updatedProject.decAmount,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseItem(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required double amount,
      }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              //style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400,),
              style: GoogleFonts.chivo(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400),
            ),
            Text(
              '₹$amount',
              //style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600,),
              style: GoogleFonts.chivo(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600,),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionListHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                //style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold,),
                style: GoogleFonts.chivo(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PieChartScreen(project: widget.project),
                    ),
                  );
                },
                child: Text(
                  'View Chart',
                  //style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold,),
                  style: GoogleFonts.chivo(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, List<Transaction> transactions, Project updatedProject) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        var transaction = transactions[index];
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Slidable(
            key: Key(transaction.id),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _showEditTransactionDialog(context, transaction, updatedProject),
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0,horizontal: 8.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: transaction.amount < 0 ? Colors.red.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        transaction.amount < 0 ? Icons.arrow_upward_outlined : Icons.arrow_downward_outlined,
                        color: transaction.amount < 0 ? Colors.red : Colors.greenAccent,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.description,
                          //style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
                          style: GoogleFonts.chivo(
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${transaction.amount}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: transaction.amount < 0 ? Colors.red : Colors.greenAccent,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(transaction.date), // Format date as needed
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddTransactionButton(BuildContext context, firestore.DocumentReference projectDoc) {
    return SizedBox(
      width: 75,
      height: 75,
      child: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _showTransactionDialog(context, projectDoc),
        child: Container(
          width: 75,
          height: 75,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFE064F7),
                Color(0xFF00B2E7),
              ],
              transform: GradientRotation(pi / 4),
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, firestore.DocumentReference projectDoc) {
    String description = '';
    double? amount;
    String transactionType = 'income';
    firestore.FirebaseFirestore.instance.collection('projects').doc(projectDoc.id);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) => amount = double.tryParse(value),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'Income',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      value: 'income',
                      groupValue: transactionType,
                      onChanged: (value) {
                        setState(() {
                          transactionType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'Expense',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      value: 'expense',
                      groupValue: transactionType,
                      onChanged: (value) {
                        setState(() {
                          transactionType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (description.isNotEmpty && amount != null && amount != 0) {
                  _createTransaction(description, amount!, projectDoc, transactionType);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _createTransaction(String description, double amount, firestore.DocumentReference projectDoc, String transactionType) {
    firestore.FirebaseFirestore.instance.collection('transactions').add({
      'description': description,
      'amount': transactionType == 'expense' ? -amount : amount,
      'date': firestore.Timestamp.now(),
      'projectId': projectDoc.id,
      'type': transactionType,
    });
    _updateProjectAmounts(projectDoc, amount, transactionType);
  }

  void _updateProjectAmounts(firestore.DocumentReference projectDoc, double amount, String transactionType) {
    if (transactionType == 'expense') {
      projectDoc.update({
        'decAmount': firestore.FieldValue.increment(-amount),
        'currentAmount': firestore.FieldValue.increment(-amount),
      });
    } else {
      projectDoc.update({
        'incAmount': firestore.FieldValue.increment(amount),
        'currentAmount': firestore.FieldValue.increment(amount),
      });
    }
  }

  void _showEditTransactionDialog(BuildContext context, Transaction transaction, Project updatedProject) {
    String description = transaction.description;
    double amount = transaction.amount;
    final firestore.DocumentReference projectDoc = firestore.FirebaseFirestore.instance.collection('projects').doc(updatedProject.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
              controller: TextEditingController(text: transaction.description),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = double.tryParse(value) ?? transaction.amount,
              controller: TextEditingController(text: transaction.amount.toString()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (description.isNotEmpty && amount != 0) {
                double amountDifference = amount - transaction.amount;
                firestore.FirebaseFirestore.instance.collection('transactions').doc(transaction.id).update({
                  'description': description,
                  'amount': amount,
                });
                if (amount < 0) {
                  projectDoc.update({
                    'decAmount': firestore.FieldValue.increment(amountDifference),
                  });
                } else {
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
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}