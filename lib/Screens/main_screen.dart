import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker_app/Screens/project_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/project.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
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
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: Text(
            'Projects',
            style: TextStyle(fontSize: 45),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: projectsCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No projects available.'));
              }

              var projects = snapshot.data!.docs
                  .map((doc) => Project.fromFirestore(doc))
                  .toList();

              return ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  var project = projects[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary, // Use the tertiary color from your theme
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                '₹${project.currentAmount.toString()}',
                                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.greenAccent),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.0), // Space between project info and date
                          Text(
                            DateFormat('dd MMM yyyy').format(project.date), // Adjust format as needed
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsScreen(project: project),
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
  }
}
