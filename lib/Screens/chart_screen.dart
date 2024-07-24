import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/project.dart';

class PieChartScreen extends StatelessWidget {
  final Project project;

  const PieChartScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    double totalAmount = project.incAmount - project.decAmount;
    double incPercentage = totalAmount > 0 ? (project.incAmount / totalAmount * 100) : 0;
    double decPercentage = totalAmount > 0 ? (project.decAmount / totalAmount * 100) : 0;

    return Scaffold(
      appBar: AppBar(title: Text('Financial Overview', style: GoogleFonts.chivo())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    if (project.incAmount > 0)
                      PieChartSectionData(
                        value: project.incAmount,
                        color: Colors.greenAccent,
                        title: '₹${project.incAmount.toInt()}\n${incPercentage.round()}%',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    if (project.decAmount < 0) // Use "< 0" to show negative amounts as expenses
                      PieChartSectionData(
                        value: -project.decAmount, // Use absolute value for display
                        color: Colors.red,
                        title: '₹${-project.decAmount.toInt()}\n${-decPercentage.round()}%',
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
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          color: Colors.greenAccent,
          title: 'Incomes',
          amount: project.incAmount,
        ),
        _buildLegendItem(
          color: Colors.red,
          title: 'Expenses',
          amount: -project.decAmount, // Use absolute value for display
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
