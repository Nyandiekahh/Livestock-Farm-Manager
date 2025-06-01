import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../providers/farm_provider.dart';
import '../../models/cow_model.dart';

class CowsScreen extends StatefulWidget {
  const CowsScreen({super.key});

  @override
  State<CowsScreen> createState() => _CowsScreenState();
}

class _CowsScreenState extends State<CowsScreen> with TickerProviderStateMixin {
  String _searchQuery = '';
  CowStatus? _filterStatus;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          final cows = _filterCows(farmProvider.cows);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                title: const Text('Cows'),
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.secondaryBrown,
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'All Cows'),
                    Tab(text: 'Quick Actions'),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _showSearchDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildCowsList(cows, farmProvider),
                _buildQuickActionsTab(farmProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Cow> _filterCows(List<Cow> cows) {
    var filtered = cows;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((cow) =>
              cow.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              cow.tagNumber
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              cow.breed.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((cow) => cow.status == _filterStatus).toList();
    }

    return filtered;
  }

  Widget _buildCowsList(List<Cow> cows, FarmProvider farmProvider) {
    if (cows.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => farmProvider.loadFarmData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cows.length,
        itemBuilder: (context, index) =>
            _buildCowCard(cows[index], farmProvider),
      ),
    );
  }

  Widget _buildCowCard(Cow cow, FarmProvider farmProvider) {
    final todayMilk = cow.getTodayMilkProduction();
    final averageMilk = cow.getAverageDailyMilkProduction();
    final healthStatus = cow.getHealthStatus();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToCowDetails(cow),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Cow Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBrown.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: cow.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              cow.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.pets,
                                      color: AppTheme.secondaryBrown),
                            ),
                          )
                        : const Icon(Icons.pets,
                            color: AppTheme.secondaryBrown, size: 28),
                  ),

                  const SizedBox(width: 16),

                  // Cow Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              cow.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.getStatusColor(cow.status.name)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppTheme.getStatusColor(cow.status.name)
                                          .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                cow.status.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      AppTheme.getStatusColor(cow.status.name),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tag: ${cow.tagNumber} • ${cow.breed}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${cow.getAgeInYears()} years old • ${cow.weight.toInt()}kg',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Menu
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleCowAction(value, cow, farmProvider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'milk',
                        child: Row(
                          children: [
                            Icon(Icons.water_drop, color: AppTheme.accentBlue),
                            SizedBox(width: 8),
                            Text('Record Milk'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'feed',
                        child: Row(
                          children: [
                            Icon(Icons.grass, color: AppTheme.primaryGreen),
                            SizedBox(width: 8),
                            Text('Record Feed'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'health',
                        child: Row(
                          children: [
                            Icon(Icons.medical_services,
                                color: AppTheme.errorRed),
                            SizedBox(width: 8),
                            Text('Health Record'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppTheme.mediumGray),
                            SizedBox(width: 8),
                            Text('Edit Details'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Statistics Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Today\'s Milk',
                      '${todayMilk.toStringAsFixed(1)}L',
                      Icons.water_drop,
                      AppTheme.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      '7-Day Average',
                      '${averageMilk.toStringAsFixed(1)}L',
                      Icons.trending_up,
                      AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      'Health',
                      healthStatus,
                      Icons.health_and_safety,
                      AppTheme.getStatusColor(healthStatus),
                    ),
                  ),
                ],
              ),

              // Milking Sessions Status
              if (cow.status == CowStatus.active) ...[
                const SizedBox(height: 12),
                _buildMilkingSessionsStatus(cow),
              ],

              // Pregnancy Status
              if (cow.isPregnant) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.pregnant_woman,
                        color: AppTheme.warningOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pregnant - Expected: ${cow.expectedCalvingDate != null ? DateFormat('MMM dd').format(cow.expectedCalvingDate!) : 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMilkingSessionsStatus(Cow cow) {
    final today = DateTime.now();
    final sessions = [
      MilkingSession.morning,
      MilkingSession.afternoon,
      MilkingSession.evening
    ];

    return Row(
      children: sessions.map((session) {
        final isDone = cow.hasMilkingRecordForSession(today, session);
        final sessionTime = _getSessionTime(session);
        final isCurrentTime = _isCurrentMilkingTime(session);

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: isDone
                  ? AppTheme.successGreen.withOpacity(0.1)
                  : isCurrentTime
                      ? AppTheme.warningOrange.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDone
                    ? AppTheme.successGreen.withOpacity(0.3)
                    : isCurrentTime
                        ? AppTheme.warningOrange.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.access_time,
                  size: 12,
                  color: isDone
                      ? AppTheme.successGreen
                      : isCurrentTime
                          ? AppTheme.warningOrange
                          : Colors.grey,
                ),
                const SizedBox(height: 2),
                Text(
                  session.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? AppTheme.successGreen
                        : isCurrentTime
                            ? AppTheme.warningOrange
                            : Colors.grey,
                  ),
                ),
                Text(
                  sessionTime,
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsTab(FarmProvider farmProvider) {
    final activeCows = farmProvider.cows
        .where((cow) => cow.status == CowStatus.active)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Milk Recording
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.water_drop, color: AppTheme.accentBlue),
                      SizedBox(width: 12),
                      Text(
                        'Quick Milk Recording',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (activeCows.isEmpty)
                    const Text('No active cows available for milking')
                  else
                    ...activeCows
                        .take(5)
                        .map((cow) => _buildQuickMilkTile(cow, farmProvider)),
                  if (activeCows.length > 5)
                    TextButton(
                      onPressed: () {
                        // Show all cows dialog
                      },
                      child: Text('View all ${activeCows.length} cows'),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Batch Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.batch_prediction,
                          color: AppTheme.primaryGreen),
                      SizedBox(width: 12),
                      Text(
                        'Batch Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading:
                        const Icon(Icons.grass, color: AppTheme.primaryGreen),
                    title: const Text('Feed All Active Cows'),
                    subtitle: Text('${activeCows.length} cows'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _batchFeedCows(activeCows, farmProvider),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy, color: AppTheme.mediumGray),
                    title: const Text('Copy Yesterday\'s Feeding'),
                    subtitle: const Text('Duplicate all feed records'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => farmProvider.copyYesterdayFeeding(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Farm Statistics
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
                        'Today\'s Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Total Milk Production',
                      '${farmProvider.getFarmStatistics()['todayMilk']?.toStringAsFixed(1) ?? '0.0'}L'),
                  _buildSummaryRow('Active Cows Milked',
                      '${_getMilkedCowsCount(activeCows)}/${activeCows.length}'),
                  _buildSummaryRow('Pending Milking Sessions',
                      '${farmProvider.getTodayUrgentTasks().length}'),
                  _buildSummaryRow('Average per Cow',
                      '${_getAverageMilkPerCow(activeCows).toStringAsFixed(1)}L'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMilkTile(Cow cow, FarmProvider farmProvider) {
    final todayMilk = cow.getTodayMilkProduction();
    final currentSession = _getCurrentMilkingSession();
    final hasCurrentSession = currentSession != null &&
        cow.hasMilkingRecordForSession(DateTime.now(), currentSession);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBrown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.pets, color: AppTheme.secondaryBrown),
        ),
        title: Text(cow.name),
        subtitle: Text('Today: ${todayMilk.toStringAsFixed(1)}L'),
        trailing: currentSession != null
            ? IconButton(
                icon: Icon(
                  hasCurrentSession ? Icons.check_circle : Icons.add_circle,
                  color: hasCurrentSession
                      ? AppTheme.successGreen
                      : AppTheme.accentBlue,
                ),
                onPressed: hasCurrentSession
                    ? null
                    : () => _quickRecordMilk(cow, currentSession, farmProvider),
              )
            : const Icon(Icons.schedule, color: Colors.grey),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No cows found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _filterStatus != null
                ? 'Try adjusting your search or filters'
                : 'Add your first cow to get started',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _filterStatus == null)
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-cow'),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Cow'),
            ),
        ],
      ),
    );
  }

  // Helper methods
  String _getSessionTime(MilkingSession session) {
    switch (session) {
      case MilkingSession.morning:
        return '6AM';
      case MilkingSession.afternoon:
        return '1PM';
      case MilkingSession.evening:
        return '6PM';
    }
  }

  bool _isCurrentMilkingTime(MilkingSession session) {
    final hour = DateTime.now().hour;
    switch (session) {
      case MilkingSession.morning:
        return hour >= 6 && hour < 10;
      case MilkingSession.afternoon:
        return hour >= 13 && hour < 16;
      case MilkingSession.evening:
        return hour >= 18 && hour < 21;
    }
  }

  MilkingSession? _getCurrentMilkingSession() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) return MilkingSession.morning;
    if (hour >= 13 && hour < 16) return MilkingSession.afternoon;
    if (hour >= 18 && hour < 21) return MilkingSession.evening;
    return null;
  }

  int _getMilkedCowsCount(List<Cow> cows) {
    final today = DateTime.now();
    return cows.where((cow) => cow.getTodayMilkProduction() > 0).length;
  }

  double _getAverageMilkPerCow(List<Cow> cows) {
    if (cows.isEmpty) return 0.0;
    final totalMilk =
        cows.fold(0.0, (sum, cow) => sum + cow.getTodayMilkProduction());
    return totalMilk / cows.length;
  }

  // Action handlers
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Cows'),
        content: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Search by name, tag, or breed...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<CowStatus?>(
              title: const Text('All'),
              value: null,
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value);
                Navigator.pop(context);
              },
            ),
            ...CowStatus.values.map((status) => RadioListTile<CowStatus?>(
                  title: Text(status.name.toUpperCase()),
                  value: status,
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() => _filterStatus = value);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _handleCowAction(String action, Cow cow, FarmProvider farmProvider) {
    switch (action) {
      case 'milk':
        Navigator.pushNamed(context, '/record-milk', arguments: cow.id);
        break;
      case 'feed':
        Navigator.pushNamed(context, '/record-feed', arguments: cow.id);
        break;
      case 'health':
        Navigator.pushNamed(context, '/record-health', arguments: cow.id);
        break;
      case 'edit':
        Navigator.pushNamed(context, '/edit-cow', arguments: cow.id);
        break;
    }
  }

  void _navigateToCowDetails(Cow cow) {
    Navigator.pushNamed(context, '/cow-details', arguments: cow.id);
  }

  void _quickRecordMilk(
      Cow cow, MilkingSession session, FarmProvider farmProvider) {
    // Show quick milk recording dialog
    showDialog(
      context: context,
      builder: (context) => _QuickMilkDialog(
          cow: cow, session: session, farmProvider: farmProvider),
    );
  }

  void _batchFeedCows(List<Cow> cows, FarmProvider farmProvider) {
    Navigator.pushNamed(context, '/batch-feed',
        arguments: cows.map((c) => c.id).toList());
  }
}

class _QuickMilkDialog extends StatefulWidget {
  final Cow cow;
  final MilkingSession session;
  final FarmProvider farmProvider;

  const _QuickMilkDialog({
    required this.cow,
    required this.session,
    required this.farmProvider,
  });

  @override
  State<_QuickMilkDialog> createState() => _QuickMilkDialogState();
}

class _QuickMilkDialogState extends State<_QuickMilkDialog> {
  final _quantityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.session.name.toUpperCase()} Milking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cow: ${widget.cow.name} (${widget.cow.tagNumber})'),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Milk Quantity (Liters)',
              hintText: 'e.g., 15.5',
              suffixText: 'L',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _recordMilk,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Record'),
        ),
      ],
    );
  }

  void _recordMilk() async {
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final record = MilkRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cowId: widget.cow.id,
        date: DateTime.now(),
        session: widget.session,
        quantity: quantity,
      );

      await widget.farmProvider.addMilkRecord(record);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Recorded ${quantity.toStringAsFixed(1)}L for ${widget.cow.name}'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording milk: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
