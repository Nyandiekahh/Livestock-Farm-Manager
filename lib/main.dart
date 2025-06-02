import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Temporarily disabled
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/farm_model.dart';
import 'models/cow_model.dart';
import 'models/chicken_model.dart';
import 'providers/farm_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/main/main_screen.dart';
import 'utils/theme.dart';
// import 'firebase_options.dart'; // Temporarily disabled

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Temporarily disable Firebase initialization
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const LivestockFarmApp());
}

class LivestockFarmApp extends StatelessWidget {
  const LivestockFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
      ],
      child: MaterialApp(
        title: 'Livestock Farm Manager',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('is_first_time') ?? true;

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        if (isFirstTime) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        } else {
          // Load farm data and navigate to main screen
          // Temporarily disabled Firebase data loading
          // final farmProvider =
          //     Provider.of<FarmProvider>(context, listen: false);
          // await farmProvider.loadFarmData();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    } catch (e) {
      print('Error initializing app: $e');
      // Navigate to welcome screen on error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
            const SizedBox(height: 30),
            const Text(
              'Livestock Farm\nManager',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
