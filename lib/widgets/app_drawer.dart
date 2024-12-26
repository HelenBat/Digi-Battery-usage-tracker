import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Use a SizedBox to force a custom height.
          SizedBox(
            height: 100,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              // Only left padding to match ListTile indentation (16 px).
              padding: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(
                // Match page background color #B3D48E
                color: Color(0xFFB3D48E),
              ),
              // Center vertically, left-align horizontally
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ),
            ),
          ),

          // Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),

          // Stats
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text('Stats'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/stats');
            },
          ),

          // Additional items can go here...
        ],
      ),
    );
  }
}
