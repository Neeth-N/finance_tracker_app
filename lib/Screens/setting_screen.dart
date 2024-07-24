import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          child: Text(
              'Settings',
            style: GoogleFonts.bodoniModa(
                fontSize: 50,
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        buildListTile(),
      ],
    );
  }

  ListTile buildListTile() {
    return ListTile(
      title: Text('Dark Mode', style: GoogleFonts.chivo()),
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
