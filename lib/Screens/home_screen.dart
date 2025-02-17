import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:finance_tracker_app/Screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 final firestore.CollectionReference projectsCollection = firestore.FirebaseFirestore.instance.collection('projects');

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,),
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          onTap: (value){
            setState((){
              index = value;
            });
          },
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
                icon: Icon(Icons.settings),
                label: 'Settings'
            )
          ],
        ),
      ),
      body: index == 0 ? MainScreen(projectsCollection: projectsCollection) : const setting_screen(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => _showAddProjectDialog(context),
          child: Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [
                    Color(0xFFE064F7),
                    Color(0xFF00B2E7)
                  ],
                  transform: GradientRotation(pi/4)
              ),
            ),
            child: const Icon(Icons.add,color: Colors.white, size: 30,),
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
        title: const Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Project Name'),
              onChanged: (value) => projectName = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Initial Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => initialAmount = double.tryParse(value) ?? 0,
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
              if (projectName.isNotEmpty) {
                projectsCollection.add({
                  'name': projectName,
                  'initialAmount': initialAmount,
                  'currentAmount': initialAmount,
                  'incAmount' : 0,
                  'decAmount' : 0,
                  'date': firestore.Timestamp.now(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}


