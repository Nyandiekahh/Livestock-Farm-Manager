import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../providers/farm_provider.dart';
import '../../models/chicken_model.dart';

class ChickensScreen extends StatefulWidget {
  const ChickensScreen({super.key});

  @override
  State<ChickensScreen> createState() => _ChickensScreenState();
}

class _ChickensScreenState extends State<ChickensScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Chickens'),
        backgroundColor: AppTheme.accentOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-chicken-group'),
          ),
        ],
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          final chickenGroups = farmProvider.chickenGroups;

          if (chickenGroups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => farmProvider.loadFarmData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chickenGroups.length,
              itemBuilder: (context, index) =>
                  _buildChickenGroupCard(chickenGroups[index], farmProvider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChickenGroupCard(ChickenGroup group, FarmProvider farmProvider) {
    final todayEggs = group.getTodayEggProduction();
    final averageEggs = group.getAverageDailyEggProduction();
    final efficiency = group.getProductionEfficiency();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToGroupDetails(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.egg,
                      color: AppTheme.accentOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              group.name,
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
                                color:
                                    AppTheme.getStatusColor(group.status.name)
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppTheme.getStatusColor(group.status.name)
                                          .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                group.status.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getStatusColor(
                                      group.status.name),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${group.chickenCount} chickens • ${group.breed}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Established ${DateFormat('MMM yyyy').format(group.establishedDate)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleGroupAction(value, group, farmProvider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'eggs',
                        child: Row(
                          children: [
                            Icon(Icons.egg_alt, color: AppTheme.accentOrange),
                            SizedBox(width: 8),
                            Text('Record Eggs'),
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
                            Text('Edit Group'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Production Statistics
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildProductionStat(
                        'Today\'s Eggs',
                        todayEggs.toString(),
                        Icons.egg_alt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProductionStat(
                        '7-Day Average',
                        averageEggs.toStringAsFixed(1),
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProductionStat(
                        'Efficiency',
                        '${(efficiency * 100).toStringAsFixed(0)}%',
                        Icons.analytics,
                      ),
                    ),
                  ],
                ),
              ),

              // Brooding Status
              if (group.isBrooding) ...[
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
                        Icons.child_care,
                        color: AppTheme.warningOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Brooding - Expected: ${group.expectedHatchDate != null ? DateFormat('MMM dd').format(group.expectedHatchDate!) : 'Unknown'}',
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

              // Quick Actions
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordEggs(group, farmProvider),
                      icon: const Icon(Icons.egg_alt, size: 16),
                      label: const Text('Record Eggs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewDetails(group),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentOrange,
                        side: const BorderSide(color: AppTheme.accentOrange),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductionStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentOrange, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.egg,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No chicken groups found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first chicken group to start tracking egg production',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add-chicken-group'),
            icon: const Icon(Icons.add),
            label: const Text('Add Chicken Group'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
            ),
          ),
        ],
      ),
    );
  }

  void _handleGroupAction(
      String action, ChickenGroup group, FarmProvider farmProvider) {
    switch (action) {
      case 'eggs':
        _recordEggs(group, farmProvider);
        break;
      case 'feed':
        Navigator.pushNamed(context, '/record-group-feed', arguments: group.id);
        break;
      case 'health':
        Navigator.pushNamed(context, '/record-group-health',
            arguments: group.id);
        break;
      case 'edit':
        Navigator.pushNamed(context, '/edit-chicken-group',
            arguments: group.id);
        break;
    }
  }

  void _navigateToGroupDetails(ChickenGroup group) {
    Navigator.pushNamed(context, '/chicken-group-details', arguments: group.id);
  }

  void _recordEggs(ChickenGroup group, FarmProvider farmProvider) {
    showDialog(
      context: context,
      builder: (context) =>
          _EggRecordDialog(group: group, farmProvider: farmProvider),
    );
  }

  void _viewDetails(ChickenGroup group) {
    Navigator.pushNamed(context, '/chicken-group-details', arguments: group.id);
  }
}

class _EggRecordDialog extends StatefulWidget {
  final ChickenGroup group;
  final FarmProvider farmProvider;

  const _EggRecordDialog({
    required this.group,
    required this.farmProvider,
  });

  @override
  State<_EggRecordDialog> createState() => _EggRecordDialogState();
}

class _EggRecordDialogState extends State<_EggRecordDialog> {
  final _eggCountController = TextEditingController();
  final _brokenEggsController = TextEditingController(text: '0');
  final _dirtyEggsController = TextEditingController(text: '0');
  String _quality = 'Good';
  bool _isLoading = false;

  @override
  void dispose() {
    _eggCountController.dispose();
    _brokenEggsController.dispose();
    _dirtyEggsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record Eggs - ${widget.group.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group: ${widget.group.chickenCount} chickens'),
            const SizedBox(height: 16),
            TextField(
              controller: _eggCountController,
              decoration: const InputDecoration(
                labelText: 'Total Eggs Collected',
                hintText: 'e.g., 25',
                suffixText: 'eggs',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _brokenEggsController,
                    decoration: const InputDecoration(
                      labelText: 'Broken',
                      suffixText: 'eggs',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dirtyEggsController,
                    decoration: const InputDecoration(
                      labelText: 'Dirty',
                      suffixText: 'eggs',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _quality,
              decoration: const InputDecoration(
                labelText: 'Quality',
              ),
              items: ['Excellent', 'Good', 'Fair', 'Poor']
                  .map((quality) => DropdownMenuItem(
                        value: quality,
                        child: Text(quality),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _quality = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _recordEggs,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentOrange,
          ),
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

  void _recordEggs() async {
    final eggCount = int.tryParse(_eggCountController.text);
    final brokenEggs = int.tryParse(_brokenEggsController.text) ?? 0;
    final dirtyEggs = int.tryParse(_dirtyEggsController.text) ?? 0;

    if (eggCount == null || eggCount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid egg count')),
      );
      return;
    }

    if (brokenEggs + dirtyEggs > eggCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Broken and dirty eggs cannot exceed total eggs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final record = EggRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: widget.group.id,
        date: DateTime.now(),
        eggCount: eggCount,
        brokenEggs: brokenEggs,
        dirtyEggs: dirtyEggs,
        quality: _quality,
      );

      await widget.farmProvider.addEggRecord(record);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recorded $eggCount eggs for ${widget.group.name}'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording eggs: $e'),
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
