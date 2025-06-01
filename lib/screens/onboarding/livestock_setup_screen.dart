import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/farm_model.dart';
import 'cow_setup_screen.dart';

class LivestockSetupScreen extends StatefulWidget {
  final Farm farm;

  const LivestockSetupScreen({super.key, required this.farm});

  @override
  State<LivestockSetupScreen> createState() => _LivestockSetupScreenState();
}

class _LivestockSetupScreenState extends State<LivestockSetupScreen> {
  int _cowCount = 0;
  int _chickenCount = 0;
  bool _hasSheep = false;
  int _sheepCount = 0;

  void _nextStep() {
    if (_cowCount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CowSetupScreen(
            farm: widget.farm,
            cowCount: _cowCount,
            chickenCount: _chickenCount,
          ),
        ),
      );
    } else {
      // Skip cow setup and go to completion
      _completeSetup();
    }
  }

  void _completeSetup() {
    // Navigate to completion screen or main app
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Setup Your Livestock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.66, // Step 2 of 3
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Step 2 of 3',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'What livestock do you have?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),

            const SizedBox(height: 32),

            // Cows Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dairy Cows',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'For milk production tracking',
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
                    const SizedBox(height: 20),
                    const Text(
                      'How many cows do you have?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _cowCount > 0
                              ? () => setState(() => _cowCount--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppTheme.secondaryBrown,
                        ),
                        Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _cowCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _cowCount++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.secondaryBrown,
                        ),
                        const Spacer(),
                        if (_cowCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              '✓ Added',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Chickens Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.egg,
                            color: AppTheme.accentOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chickens',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'For egg production tracking',
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
                    const SizedBox(height: 20),
                    const Text(
                      'How many chickens do you have?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _chickenCount > 0
                              ? () => setState(() => _chickenCount--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppTheme.accentOrange,
                        ),
                        Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _chickenCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _chickenCount++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.accentOrange,
                        ),
                        const Spacer(),
                        if (_chickenCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              '✓ Added',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sheep Section (Optional)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.pets,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sheep (Optional)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Basic livestock tracking',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _hasSheep,
                          onChanged: (value) => setState(() {
                            _hasSheep = value;
                            if (!value) _sheepCount = 0;
                          }),
                          activeColor: AppTheme.primaryGreen,
                        ),
                      ],
                    ),
                    if (_hasSheep) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'How many sheep do you have?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _sheepCount > 0
                                ? () => setState(() => _sheepCount--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.grey[600],
                          ),
                          Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _sheepCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _sheepCount++),
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Summary
            if (_cowCount > 0 ||
                _chickenCount > 0 ||
                (_hasSheep && _sheepCount > 0))
              Card(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_cowCount > 0)
                        Text('• $_cowCount dairy cows for milk production'),
                      if (_chickenCount > 0)
                        Text('• $_chickenCount chickens for egg production'),
                      if (_hasSheep && _sheepCount > 0)
                        Text('• $_sheepCount sheep for general tracking'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    (_cowCount > 0 || _chickenCount > 0) ? _nextStep : null,
                child: Text(
                  _cowCount > 0 ? 'Continue to Cow Setup' : 'Complete Setup',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Skip Button
            if (_cowCount == 0 && _chickenCount == 0)
              Center(
                child: TextButton(
                  onPressed: _completeSetup,
                  child: const Text(
                    'Skip for now - I\'ll add livestock later',
                    style: TextStyle(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
