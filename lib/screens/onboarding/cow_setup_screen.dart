import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../models/farm_model.dart';
import '../../models/cow_model.dart';
import '../../models/chicken_model.dart';
import '../../providers/farm_provider.dart';
import '../main/main_screen.dart';

class CowSetupScreen extends StatefulWidget {
  final Farm farm;
  final int cowCount;
  final int chickenCount;

  const CowSetupScreen({
    super.key,
    required this.farm,
    required this.cowCount,
    required this.chickenCount,
  });

  @override
  State<CowSetupScreen> createState() => _CowSetupScreenState();
}

class _CowSetupScreenState extends State<CowSetupScreen> {
  final PageController _pageController = PageController();
  int _currentCowIndex = 0;
  List<Cow> _cows = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCows();
  }

  void _initializeCows() {
    _cows = List.generate(
      widget.cowCount,
      (index) => Cow(
        id: 'cow_${DateTime.now().millisecondsSinceEpoch}_$index',
        name: '',
        tagNumber: '',
        breed: '',
        birthDate: DateTime.now()
            .subtract(const Duration(days: 365 * 2)), // Default 2 years old
        color: '',
        weight: 400.0, // Default weight
      ),
    );
  }

  void _nextCow() {
    if (_currentCowIndex < widget.cowCount - 1) {
      setState(() {
        _currentCowIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  void _previousCow() {
    if (_currentCowIndex > 0) {
      setState(() {
        _currentCowIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSetup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);

      // Initialize farm
      await farmProvider.initializeFarm(widget.farm);

      // Add all cows
      for (final cow in _cows) {
        if (cow.name.isNotEmpty && cow.tagNumber.isNotEmpty) {
          await farmProvider.addCow(cow);
        }
      }

      // Add default chicken group if chickens were specified
      if (widget.chickenCount > 0) {
        final chickenGroup = ChickenGroup(
          id: 'chicken_group_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Main Flock',
          breed: 'Mixed',
          chickenCount: widget.chickenCount,
          establishedDate: DateTime.now(),
        );
        await farmProvider.addChickenGroup(chickenGroup);
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up farm: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text('Setup Cow ${_currentCowIndex + 1} of ${widget.cowCount}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentCowIndex > 0
              ? _previousCow
              : () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step 3 of 3',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_currentCowIndex + 1}/${widget.cowCount}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentCowIndex + 1) / widget.cowCount,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen),
                ),
              ],
            ),
          ),

          // Cow Setup Form
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) =>
                  setState(() => _currentCowIndex = index),
              itemCount: widget.cowCount,
              itemBuilder: (context, index) => _buildCowForm(index),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentCowIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousCow,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentCowIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextCow,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentCowIndex < widget.cowCount - 1
                            ? 'Next Cow'
                            : 'Complete Setup'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCowForm(int index) {
    final cow = _cows[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: AppTheme.secondaryBrown,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cow ${index + 1}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Basic information for your cow',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Cow Name
                  TextFormField(
                    initialValue: cow.name,
                    decoration: const InputDecoration(
                      labelText: 'Cow Name *',
                      hintText: 'e.g., Bella, Daisy, Moo',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    onChanged: (value) {
                      cow.name = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tag Number
                  TextFormField(
                    initialValue: cow.tagNumber,
                    decoration: const InputDecoration(
                      labelText: 'Tag Number *',
                      hintText: 'e.g., 001, A123, COW-001',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    onChanged: (value) {
                      cow.tagNumber = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Breed
                  TextFormField(
                    initialValue: cow.breed,
                    decoration: const InputDecoration(
                      labelText: 'Breed',
                      hintText: 'e.g., Holstein, Jersey, Friesian',
                      prefixIcon: Icon(Icons.category),
                    ),
                    onChanged: (value) {
                      cow.breed = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Color/Markings
                  TextFormField(
                    initialValue: cow.color,
                    decoration: const InputDecoration(
                      labelText: 'Color/Markings',
                      hintText: 'e.g., Black and white, Brown, Spotted',
                      prefixIcon: Icon(Icons.palette),
                    ),
                    onChanged: (value) {
                      cow.color = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Weight
                  TextFormField(
                    initialValue: cow.weight.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      hintText: 'e.g., 450',
                      prefixIcon: Icon(Icons.monitor_weight),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      cow.weight = double.tryParse(value) ?? cow.weight;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Optional Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Optional Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can add more details later in the cow profile',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Birth Date
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: const Text('Birth Date'),
                    subtitle: Text(
                      '${cow.birthDate.day}/${cow.birthDate.month}/${cow.birthDate.year}',
                    ),
                    trailing: const Icon(Icons.edit),
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: cow.birthDate,
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 20)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          cow.birthDate = date;
                        });
                      }
                    },
                  ),

                  // Status
                  ListTile(
                    leading: const Icon(Icons.health_and_safety),
                    title: const Text('Status'),
                    subtitle: Text(cow.status.name.toUpperCase()),
                    trailing: const Icon(Icons.edit),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _showStatusDialog(cow),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Setup Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Quick Setup Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Name and Tag Number are required\n• You can skip optional fields for now\n• All information can be edited later\n• Photos can be added from the cow profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(Cow cow) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cow Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CowStatus.values
              .map((status) => RadioListTile<CowStatus>(
                    title: Text(status.name.toUpperCase()),
                    value: status,
                    groupValue: cow.status,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          cow.status = value;
                        });
                        Navigator.pop(context);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
