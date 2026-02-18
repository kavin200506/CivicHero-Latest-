import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';
import 'dashboard_screen.dart';
// import 'users_screen.dart'; // To be implemented
// import 'reports_screen.dart'; // To be implemented
import 'camera_setup_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Users Feature Coming Soon', style: TextStyle(fontSize: 24, color: Colors.grey)),
        ],
      ),
    ),
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Reports Feature Coming Soon', style: TextStyle(fontSize: 24, color: Colors.grey)),
        ],
      ),
    ),
     const CameraSetupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Consumer<AuthService>(
                    builder: (_, auth, __) => IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Sign Out',
                      onPressed: () async {
                         await auth.signOut();
                         // Navigator.of(context).pushReplacementNamed('/'); // Handled by auth stream usually, but good to have
                      },
                    ),
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assessment_outlined),
                selectedIcon: Icon(Icons.assessment),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(Icons.camera_alt),
                label: Text('Cameras'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
