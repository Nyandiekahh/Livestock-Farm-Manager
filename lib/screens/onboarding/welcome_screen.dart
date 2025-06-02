import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'farm_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Welcome Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 60,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Welcome Text
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Text(
                  'Livestock Farm\nManager',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 30),

                // Features List - NO MORE Flexible widget!
                _buildFeatureItem(
                  Icons.pets,
                  'Manage Your Livestock',
                  'Track individual cows, chickens, and their health records',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.water_drop,
                  'Track Milk Production',
                  'Record daily milking sessions with detailed analytics',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.egg,
                  'Monitor Egg Production',
                  'Keep track of daily egg collection from chicken groups',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.grass,
                  'Feeding Management',
                  'Record feed consumption, costs, and optimize nutrition',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.medical_services,
                  'Health Monitoring',
                  'Track vaccinations, treatments, and health status',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.analytics,
                  'Farm Analytics',
                  'Get insights on productivity, costs, and trends',
                ),

                const SizedBox(height: 40),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FarmSetupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Terms Text
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),

                const SizedBox(height: 40), // Extra bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
