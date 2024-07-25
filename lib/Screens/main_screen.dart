import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker_app/Screens/project_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Models/project.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.projectsCollection,
  });

  final CollectionReference<Object?> projectsCollection;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projects',
                style: GoogleFonts.bodoniModa(
                  fontSize: 50,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                    }
                  });
                },
              ),
            ],
          ),
        ),
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Projects...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        const SizedBox(height: 17),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: widget.projectsCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No projects available.'));
              }

              var projects = snapshot.data!.docs
                  .map((doc) => Project.fromFirestore(doc))
                  .where((project) =>
                  project.name.toLowerCase().contains(_searchQuery))
                  .toList();

              if (projects.isEmpty) {
                return const Center(child: Text('No projects match your search.'));
              }

              return ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  var project = projects[index];
                  return ProjectTile(project: project);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProjectTile extends StatelessWidget {
  const ProjectTile({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: GoogleFonts.chivo(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '₹${project.currentAmount.toString()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.greenAccent),
                ),
              ],
            ),
            const SizedBox(height: 4.0), // Space between project info and date
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
  }
}
