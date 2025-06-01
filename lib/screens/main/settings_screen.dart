import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';
import '../../providers/farm_provider.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: Consumer2<FarmProvider, AuthProvider>(
        builder: (context, farmProvider, authProvider, child) {
          final farm = farmProvider.farm;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farm Information Card
                if (farm != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.agriculture,
                                  color: AppTheme.primaryGreen),
                              SizedBox(width: 12),
                              Text(
                                'Farm Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Farm Name', farm.name),
                          _buildInfoRow('Location', farm.location),
                          _buildInfoRow('Owner', farm.ownerName),
                          _buildInfoRow('Contact', farm.contactNumber),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _editFarmInfo(farm),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Farm Info'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Statistics Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics, color: AppTheme.primaryGreen),
                            SizedBox(width: 12),
                            Text(
                              'Farm Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (farm != null) ...[
                          _buildStatRow(
                              'Total Cows', '${farmProvider.cows.length}'),
                          _buildStatRow('Active Cows',
                              '${farmProvider.cows.where((c) => c.status.name == 'active').length}'),
                          _buildStatRow('Chicken Groups',
                              '${farmProvider.chickenGroups.length}'),
                          _buildStatRow('Total Chickens',
                              '${farmProvider.chickenGroups.fold(0, (sum, g) => sum + g.chickenCount)}'),
                          _buildStatRow('Milk Records',
                              '${farmProvider.milkRecords.length}'),
                          _buildStatRow('Egg Records',
                              '${farmProvider.eggRecords.length}'),
                        ] else
                          const Text('No farm data available'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // App Settings Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.settings, color: AppTheme.primaryGreen),
                            SizedBox(width: 12),
                            Text(
                              'App Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notifications'),
                          subtitle: const Text(
                              'Manage milking and feeding reminders'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showNotificationSettings(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text('Milking Schedule'),
                          subtitle: const Text('Customize milking times'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showMilkingSchedule(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.backup),
                          title: const Text('Data Backup'),
                          subtitle: const Text('Export and backup farm data'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showDataBackup(),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Support Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.help, color: AppTheme.primaryGreen),
                            SizedBox(width: 12),
                            Text(
                              'Support & Help',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('Help & FAQ'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showHelp(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.feedback),
                          title: const Text('Send Feedback'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _sendFeedback(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('About'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showAbout(),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Danger Zone Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: AppTheme.errorRed),
                            SizedBox(width: 12),
                            Text(
                              'Danger Zone',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.refresh,
                              color: AppTheme.warningOrange),
                          title: const Text('Reset Farm Data'),
                          subtitle:
                              const Text('Clear all data and start fresh'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _confirmResetData(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete_forever,
                              color: AppTheme.errorRed),
                          title: const Text('Delete Farm'),
                          subtitle: const Text('Permanently delete this farm'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _confirmDeleteFarm(),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App Version
                Center(
                  child: Text(
                    'Livestock Farm Manager v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _editFarmInfo(farm) {
    // Navigate to farm edit screen
    Navigator.pushNamed(context, '/edit-farm');
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text('Milking Reminders'),
              subtitle: Text('Get notified at milking times'),
              value: true,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('Health Alerts'),
              subtitle: Text('Get notified about overdue vaccinations'),
              value: true,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('Production Reports'),
              subtitle: Text('Daily production summaries'),
              value: false,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMilkingSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Milking Schedule'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current milking times:'),
            SizedBox(height: 12),
            Text('• Morning: 6:00 AM'),
            Text('• Afternoon: 1:00 PM'),
            Text('• Evening: 6:00 PM'),
            SizedBox(height: 16),
            Text(
              'Tap to customize these times',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Backup'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your farm data is automatically backed up to the cloud.'),
            SizedBox(height: 12),
            Text('You can also export your data for your records:'),
            SizedBox(height: 8),
            Text('• Export as CSV'),
            Text('• Export as PDF report'),
            Text('• Export as JSON backup'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Export Data'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Q: How do I add a new cow?'),
              Text(
                'A: Go to the Cows tab and tap the + button.',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text('Q: How do I record milk production?'),
              Text(
                'A: Use the Quick Record button on the Dashboard or go to the cow\'s profile.',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text('Q: Can I backup my data?'),
              Text(
                'A: Yes, your data is automatically backed up to the cloud.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us what you think about the app...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Livestock Farm Manager',
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.agriculture,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: const [
        Text(
            'A comprehensive mobile application for managing livestock and dairy farm operations.'),
        SizedBox(height: 16),
        Text('Features:'),
        Text('• Individual cow management'),
        Text('• Milk production tracking'),
        Text('• Chicken group management'),
        Text('• Health monitoring'),
        Text('• Production analytics'),
      ],
    );
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Farm Data'),
        content: const Text(
          'Are you sure you want to reset all farm data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _resetData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFarm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm'),
        content: const Text(
          'Are you sure you want to permanently delete this farm? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteFarm(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete Farm'),
          ),
        ],
      ),
    );
  }

  void _resetData() async {
    Navigator.pop(context); // Close dialog

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      farmProvider.clearData();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _deleteFarm() async {
    Navigator.pop(context); // Close dialog

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      farmProvider.clearData();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting farm: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
