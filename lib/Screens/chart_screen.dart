import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../Models/project.dart';

class PieChartScreen extends StatelessWidget {
  final Project project;

  const PieChartScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final firestore.DocumentReference projectDoc = firestore.FirebaseFirestore.instance.collection('projects').doc(project.id);

    return Scaffold(
      appBar: AppBar(title: Text('Financial Overview', style: GoogleFonts.chivo())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<firestore.DocumentSnapshot>(
          stream: projectDoc.snapshots(),
          builder: (context, projectSnapshot) {
            if (!projectSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (projectSnapshot.hasError) {
              return Center(child: Text('Error: ${projectSnapshot.error}'));
            }

            final updatedProject = Project.fromFirestore(projectSnapshot.data!);

            double totalAmount = updatedProject.incAmount - updatedProject.decAmount;
            double incPercentage = totalAmount > 0 ? (updatedProject.incAmount / totalAmount * 100) : 0;
            double decPercentage = totalAmount > 0 ? (updatedProject.decAmount / totalAmount * 100) : 0;

            return Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (updatedProject.incAmount > 0)
                          PieChartSectionData(
                            value: updatedProject.incAmount,
                            color: Colors.greenAccent,
                            title: '₹${updatedProject.incAmount.toInt()}\n${incPercentage.round()}%',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                        if (updatedProject.decAmount < 0)
                          PieChartSectionData(
                            value: -updatedProject.decAmount,
                            color: Colors.red,
                            title: '₹${-updatedProject.decAmount.toInt()}\n${-decPercentage.round()}%',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 16, color: Colors.greenAccent),
                          ),
                      ],
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 90,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLegend(context, updatedProject),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Project updatedProject) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          color: Colors.greenAccent,
          title: 'Incomes',
          amount: updatedProject.incAmount,
        ),
        _buildLegendItem(
          color: Colors.red,
          title: 'Expenses',
          amount: -updatedProject.decAmount, // Use absolute value for display
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String title, required double amount}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title: ₹$amount',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
