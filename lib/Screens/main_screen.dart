import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker_app/Screens/project_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/project.dart';

class main_screen extends StatelessWidget {
  const main_screen({
    super.key,
    required this.projectsCollection,
  });

  final CollectionReference<Object?> projectsCollection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 16.0),
          child: Text(
              'Projects',
            style: TextStyle(fontSize: 45),
          ),
        ),
        Expanded(
          child: StreamBuilder(
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
        ),
      ],
    );
  }
}