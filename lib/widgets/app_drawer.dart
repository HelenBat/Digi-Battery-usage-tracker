import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // An optional header at the top
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),

          // Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Navigator.pushReplacementNamed(context, '/'); 
              // or Navigator.pushNamed if you'd like multiple stack pushes
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

          // Future pages can be added here
          // e.g. a Profile page:
          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Profile'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushReplacementNamed(context, '/profile');
          //   },
          // ),
        ],
      ),
    );
  }
}
