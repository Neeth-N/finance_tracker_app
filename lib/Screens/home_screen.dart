import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker_app/Screens/project_details_screen.dart';
import 'package:flutter/material.dart';

import '../Models/project.dart';

class HomeScreen extends StatelessWidget {
  final CollectionReference projectsCollection = FirebaseFirestore.instance.collection('projects');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Projects')),
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
      body: StreamBuilder(
        stream: projectsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var projects = snapshot.data!.docs.map((doc) => Project.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              var project = projects[index];
              return ListTile(
                title: Text(project.name),
                subtitle: Text('Current Amount: ₹${project.currentAmount.toString()}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProjectDetailsScreen(project: project),
                )),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => _showAddProjectDialog(context),
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

  void _showAddProjectDialog(BuildContext context) {
    String projectName = '';
    double initialAmount = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Project Name'),
              onChanged: (value) => projectName = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Initial Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => initialAmount = double.tryParse(value) ?? 0,
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
              if (projectName.isNotEmpty) {
                projectsCollection.add({
                  'name': projectName,
                  'initialAmount': initialAmount,
                  'currentAmount': initialAmount,
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
}
