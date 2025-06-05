import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = true;
  bool _isFirstTime = false;
  String? _errorMessage;

  User? get user => _user;
  User? get currentUser => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isFirstTime => _isFirstTime;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      debugPrint('Auth state changed: $event');

      if (event == AuthChangeEvent.signedIn && session?.user != null) {
        _handleSignIn(session!.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _handleSignOut();
      } else if (event == AuthChangeEvent.initialSession && session?.user != null) {
        _handleSignIn(session!.user);
      }
    });

    final session = Supabase.instance.client.auth.currentSession;
    if (session?.user != null) {
      _handleSignIn(session!.user);
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleSignIn(User user) async {
    try {
      print('🔄 AuthProvider: Handling sign in for user: ${user.email}');
      _user = user;
      _errorMessage = null;
      _isLoading = true;
      notifyListeners(); // Notify immediately when user is set

      try {
        print('📋 AuthProvider: Loading user profile...');
        _userProfile = await _supabaseService.getUserProfile(user.id);
        print('✅ AuthProvider: User profile loaded successfully');
        
        // Check if profile needs completion based on existing data
        _isFirstTime = !_userProfile!.isProfileComplete;
        print('🔍 AuthProvider: Profile complete: ${_userProfile!.isProfileComplete}');
        print('🔍 AuthProvider: Is first time: $_isFirstTime');
      } catch (e) {
        print('⚠️ AuthProvider: User profile not found, creating new profile');
        print('📝 AuthProvider: Profile error details: $e');
        
        try {
          print('🔨 AuthProvider: Creating user profile...');
          await _createUserProfile(user);
          print('✅ AuthProvider: New user profile created successfully');
          _isFirstTime = true;
        } catch (createError) {
          print('❌ AuthProvider: Failed to create user profile: $createError');
          
          // Create a minimal profile locally if database creation fails
          _userProfile = UserModel(
            id: user.id,
            name: user.userMetadata?['full_name'] ?? 
                  user.userMetadata?['name'] ?? 
                  user.email?.split('@')[0] ?? 
                  'User',
            email: user.email ?? '',
            spiralStage: 'beige',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          _isFirstTime = true;
          print('⚠️ Created minimal local profile as fallback');
        }
      }

      _isLoading = false;
      print('✅ AuthProvider: Sign in handling complete');
      notifyListeners();
    } catch (e) {
      print('💥 AuthProvider: Error handling sign in: $e');
      
      // Don't fail completely, allow user to continue
      _isFirstTime = true;
      _errorMessage = null;
      _isLoading = false;
      print('⚠️ AuthProvider: Continuing with minimal setup due to error');
      notifyListeners();
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      print('🔨 Creating user profile for: ${user.id}');
      
      final name = user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          user.email?.split('@')[0] ??
          'User';

      print('👤 Using name: $name');

      // Try to create the profile
      await _supabaseService.createUserProfile(
        user.id,
        name,
        user.email ?? '',
      );

      print('✅ Profile created, now fetching...');
      
      // Try to fetch the created profile
      _userProfile = await _supabaseService.getUserProfile(user.id);
      print('✅ Profile fetched successfully');
      
    } catch (e) {
      print('❌ Error in _createUserProfile: $e');
      throw Exception('Failed to create user profile in database: $e');
    }
  }

  void _handleSignOut() {
    _user = null;
    _userProfile = null;
    _isFirstTime = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    return await signInWithEmail(email: email, password: password);
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔑 Attempting sign in for: $email');
      
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Sign in successful');
        // Don't set _isLoading = false here, let _handleSignIn do it
        return true;
      } else {
        print('❌ Sign in failed - no user returned');
        _errorMessage = 'Sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      print('❌ Sign in AuthException: ${e.message}');
      String errorMessage = 'Sign in failed';
      
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        errorMessage = 'Please check your email and confirm your account.';
      } else if (e.message.toLowerCase().contains('too many requests')) {
        errorMessage = 'Too many attempts. Please try again later.';
      } else {
        errorMessage = e.message;
      }
      
      _errorMessage = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('💥 Sign in unexpected error: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    return await signUpWithEmail(email: email, password: password, name: name);
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔄 AuthProvider: Starting sign up process');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📧 AuthProvider: Attempting to sign up with email: $email');
      print('👤 AuthProvider: Name: $name');
      
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'full_name': name},
      );

      print('📋 AuthProvider: Sign up response received');
      print('👤 User ID: ${response.user?.id}');
      print('📧 Email: ${response.user?.email}');
      print('✅ Email confirmed: ${response.user?.emailConfirmedAt != null}');

      if (response.user != null) {
        print('✅ AuthProvider: Sign up successful');
        
        // Check if email confirmation is required
        if (response.user!.emailConfirmedAt == null) {
          print('📬 AuthProvider: Email confirmation required');
          _errorMessage = 'Please check your email and click the confirmation link to complete registration.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('❌ AuthProvider: Sign up failed - no user returned');
        _errorMessage = 'Sign up failed - please try again';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      print('❌ AuthProvider: Sign up AuthException: ${e.message}');
      print('❌ AuthProvider: Status code: ${e.statusCode}');
      
      String errorMessage = 'Sign up failed';
      
      if (e.statusCode == '422') {
        if (e.message.toLowerCase().contains('user already registered') ||
            e.message.toLowerCase().contains('email already registered') ||
            e.message.toLowerCase().contains('already been registered')) {
          errorMessage = 'An account with this email already exists. Please sign in instead.';
        } else if (e.message.toLowerCase().contains('password')) {
          errorMessage = 'Password must be at least 6 characters long.';
        } else if (e.message.toLowerCase().contains('email')) {
          errorMessage = 'Please enter a valid email address.';
        } else {
          errorMessage = 'Registration failed: ${e.message}';
        }
      } else if (e.message.toLowerCase().contains('signup is disabled')) {
        errorMessage = 'New user registration is currently disabled. Please contact support.';
      } else {
        errorMessage = e.message;
      }
      
      _errorMessage = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('💥 AuthProvider: Sign up unexpected error: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      print('🔄 Starting Google sign in');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String? redirectUrl;
      if (kIsWeb) {
        final host = Uri.base.host;
        if (host.contains('localhost')) {
          redirectUrl = 'http://localhost:${Uri.base.port}';
        } else if (host.contains('netlify.app')) {
          redirectUrl = 'https://retven-nr.netlify.app';
        } else {
          redirectUrl = Uri.base.origin;
        }
      }

      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );

      print('✅ Google OAuth initiated: $response');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Google sign in error: $e');
      _errorMessage = 'Google sign in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabaseService.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      _errorMessage = 'Sign out failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      await _supabaseService.updateUserProfile(updatedUser);
      _userProfile = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    _isFirstTime = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
