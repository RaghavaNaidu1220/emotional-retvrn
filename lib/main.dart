import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'providers/auth_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/practice_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/dashboard/home_screen.dart';
import 'screens/profile/profile_setup_screen.dart';
import 'services/whisper_service.dart';
import 'services/openai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully');
  } catch (e) {
    debugPrint('No .env file found, using default values: $e');
  }
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: true,
  );
  
  // Initialize services
  WhisperService().initialize();
  OpenAIService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => PracticeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Emotional Spiral',
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('🔍 AuthWrapper: isLoading=${authProvider.isLoading}, user=${authProvider.user?.email}, isFirstTime=${authProvider.isFirstTime}');
        
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        
        if (authProvider.user == null) {
          return const LandingScreen();
        }
        
        // User is authenticated, check if profile setup is needed
        if (authProvider.isFirstTime) {
          print('🔄 AuthWrapper: Redirecting to profile setup');
          return const ProfileSetupScreen();
        }
        
        print('🏠 AuthWrapper: Redirecting to home');
        return const HomeScreen();
      },
    );
  }
}
