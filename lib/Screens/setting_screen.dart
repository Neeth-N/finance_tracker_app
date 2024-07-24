import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Themes/theme_provider.dart';

class setting_screen extends StatelessWidget {
  const setting_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Text(
              'Settings',
            style: TextStyle(
              fontSize: 45,
            ),
          ),
        ),
        buildListTile(),
      ],
    );
  }

  ListTile buildListTile() {
    return ListTile(
      title: Text('Dark Mode'),
      trailing: Consumer<ThemeProvider>(
        builder: (context, themeNotifier, child) {
          return Switch(
            value: themeNotifier.isDarkMode,
            onChanged: (value) {
              themeNotifier.toggleTheme();
            },
          );
        },
      ),
    );
  }
}
