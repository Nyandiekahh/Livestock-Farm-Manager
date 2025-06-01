import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../providers/farm_provider.dart';
import '../../models/cow_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    await farmProvider.loadFarmData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          final farm = farmProvider.farm;
          final stats = farmProvider.getFarmStatistics();
          final urgentTasks = farmProvider.getTodayUrgentTasks();

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  pinned: true,
                  backgroundColor: AppTheme.primaryGreen,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          farm?.name ?? 'Your Farm',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () => _showNotifications(urgentTasks),
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Today's Date
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Urgent Tasks Section
                      if (urgentTasks.isNotEmpty) ...[
                        _buildUrgentTasksSection(urgentTasks),
                        const SizedBox(height: 20),
                      ],

                      // Quick Stats Grid
                      _buildQuickStatsGrid(stats),

                      const SizedBox(height: 20),

                      // Today's Production
                      _buildTodayProductionCard(stats),

                      const SizedBox(height: 20),

                      // Recent Activity
                      _buildRecentActivityCard(farmProvider),

                      const SizedBox(height: 20),

                      // Farm Overview
                      _buildFarmOverviewCard(stats),

                      const SizedBox(height: 100), // Space for FAB
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildUrgentTasksSection(List<Map<String, dynamic>> urgentTasks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: AppTheme.errorRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Urgent Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    urgentTasks.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...urgentTasks.take(3).map((task) => _buildTaskItem(task)),
            if (urgentTasks.length > 3)
              TextButton(
                onPressed: () => _showAllTasks(urgentTasks),
                child: Text('View all ${urgentTasks.length} tasks'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final isOverdue = task['priority'] == 'overdue';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppTheme.errorRed.withOpacity(0.1)
            : AppTheme.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue
              ? AppTheme.errorRed.withOpacity(0.3)
              : AppTheme.warningOrange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.error : Icons.access_time,
            color: isOverdue ? AppTheme.errorRed : AppTheme.warningOrange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? AppTheme.errorRed : AppTheme.darkGray,
                  ),
                ),
                Text(
                  task['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => _handleTaskAction(task),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Active Cows',
          '${stats['activeCows'] ?? 0}',
          Icons.pets,
          AppTheme.secondaryBrown,
        ),
        _buildStatCard(
          'Chickens',
          '${stats['totalChickens'] ?? 0}',
          Icons.egg,
          AppTheme.accentOrange,
        ),
        _buildStatCard(
          'Today\'s Milk',
          '${(stats['todayMilk'] ?? 0.0).toStringAsFixed(1)}L',
          Icons.water_drop,
          AppTheme.accentBlue,
        ),
        _buildStatCard(
          'Today\'s Eggs',
          '${stats['todayEggs'] ?? 0}',
          Icons.egg_alt,
          AppTheme.accentOrange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProductionCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Production',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProductionItem(
                    'Milk Production',
                    '${(stats['todayMilk'] ?? 0.0).toStringAsFixed(1)} Liters',
                    Icons.water_drop,
                    AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProductionItem(
                    'Egg Collection',
                    '${stats['todayEggs'] ?? 0} Eggs',
                    Icons.egg,
                    AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(FarmProvider farmProvider) {
    final recentMilkRecords = farmProvider.milkRecords.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to records screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentMilkRecords.isEmpty)
              const Text(
                'No recent activity',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...recentMilkRecords
                  .map((record) => _buildActivityItem(record, farmProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(MilkRecord record, FarmProvider farmProvider) {
    final cow = farmProvider.cows.firstWhere(
      (c) => c.id == record.cowId,
      orElse: () => Cow(
        id: '',
        name: 'Unknown',
        tagNumber: '',
        breed: '',
        birthDate: DateTime.now(),
        color: '',
        weight: 0,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.water_drop,
              color: AppTheme.accentBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Milked ${cow.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${record.quantity.toStringAsFixed(1)}L - ${record.session.name.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('HH:mm').format(record.date),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmOverviewCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOverviewRow('Total Cows', '${stats['totalCows'] ?? 0}'),
            _buildOverviewRow('Active Cows', '${stats['activeCows'] ?? 0}'),
            _buildOverviewRow(
                'Chicken Groups', '${stats['chickenGroups'] ?? 0}'),
            _buildOverviewRow(
                'Total Chickens', '${stats['totalChickens'] ?? 0}'),
            _buildOverviewRow('Pending Tasks', '${stats['pendingTasks'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(List<Map<String, dynamic>> urgentTasks) {
    // Show notifications dialog or navigate to notifications screen
  }

  void _showAllTasks(List<Map<String, dynamic>> urgentTasks) {
    // Show all tasks dialog or navigate to tasks screen
  }

  void _handleTaskAction(Map<String, dynamic> task) {
    // Handle task action (e.g., navigate to milking screen)
  }
}
