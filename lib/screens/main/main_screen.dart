import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../providers/farm_provider.dart';
import 'dashboard_screen.dart';
import 'cows_screen.dart';
import 'chickens_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CowsScreen(),
    const ChickensScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          if (farmProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (farmProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading farm data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    farmProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      farmProvider.loadFarmData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return IndexedStack(
            index: _selectedIndex,
            children: _screens,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.mediumGray,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Cows',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.egg),
            label: 'Chickens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0: // Dashboard - Quick Record
        return FloatingActionButton.extended(
          onPressed: () => _showQuickRecordDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Quick Record'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        );
      case 1: // Cows - Add Cow
        return FloatingActionButton(
          onPressed: () => _navigateToAddCow(),
          backgroundColor: AppTheme.secondaryBrown,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        );
      case 2: // Chickens - Add Group
        return FloatingActionButton(
          onPressed: () => _navigateToAddChickenGroup(),
          backgroundColor: AppTheme.accentOrange,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _showQuickRecordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Quick Record',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildQuickActionCard(
                    'Record Milk',
                    'Log milking session for a cow',
                    Icons.water_drop,
                    AppTheme.accentBlue,
                    () => _navigateToMilkRecord(),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    'Record Feeding',
                    'Log feeding for cows',
                    Icons.grass,
                    AppTheme.primaryGreen,
                    () => _navigateToFeedRecord(),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    'Record Eggs',
                    'Log egg collection',
                    Icons.egg,
                    AppTheme.accentOrange,
                    () => _navigateToEggRecord(),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    'Copy Yesterday\'s Feeding',
                    'Duplicate yesterday\'s feed records',
                    Icons.copy,
                    AppTheme.mediumGray,
                    () => _copyYesterdayFeeding(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  void _navigateToAddCow() {
    // Navigate to add cow screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Cow feature coming soon!')),
    );
  }

  void _navigateToAddChickenGroup() {
    // Navigate to add chicken group screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Chicken Group feature coming soon!')),
    );
  }

  void _navigateToMilkRecord() {
    // Navigate to milk record screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Milk Record feature coming soon!')),
    );
  }

  void _navigateToFeedRecord() {
    // Navigate to feed record screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feed Record feature coming soon!')),
    );
  }

  void _navigateToEggRecord() {
    // Navigate to egg record screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Egg Record feature coming soon!')),
    );
  }

  void _copyYesterdayFeeding() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Copying yesterday\'s feeding...'),
          ],
        ),
      ),
    );

    await farmProvider.copyYesterdayFeeding();

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yesterday\'s feeding records copied successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }
}
