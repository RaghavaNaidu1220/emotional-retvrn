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
  User? get currentUser => _user; // Add this getter
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isFirstTime => _isFirstTime;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      debugPrint('Auth state changed: $event');
      
      if (event == AuthChangeEvent.signedIn && session?.user != null) {
        _handleSignIn(session!.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _handleSignOut();
      }
    });

    // Check current session
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
      _user = user;
      _errorMessage = null;
      
      // Try to load user profile
      try {
        _userProfile = await _supabaseService.getUserProfile(user.id);
        _isFirstTime = false;
      } catch (e) {
        // Profile doesn't exist, this is a new user
        debugPrint('User profile not found, creating new profile');
        await _createUserProfile(user);
        _isFirstTime = true;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling sign in: $e');
      _errorMessage = 'Failed to load user profile';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      final name = user.userMetadata?['full_name'] ?? 
                   user.userMetadata?['name'] ?? 
                   user.email?.split('@')[0] ?? 
                   'User';
      
      await _supabaseService.createUserProfile(
        user.id,
        name,
        user.email ?? '',
      );
      
      _userProfile = await _supabaseService.getUserProfile(user.id);
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      throw Exception('Failed to create user profile');
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
    return await signInWithEmail(email, password);
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.signIn(email, password);
      
      if (response.user != null) {
        // Auth state change listener will handle the rest
        return true;
      } else {
        _errorMessage = 'Sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.signUp(email, password);
      
      if (response.user != null) {
        // Create user profile
        await _supabaseService.createUserProfile(
          response.user!.id,
          name,
          email,
        );
        return true;
      } else {
        _errorMessage = 'Sign up failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.signUp(email, password);
      
      if (response.user != null) {
        // Auth state change listener will handle the rest
        return true;
      } else {
        _errorMessage = 'Sign up failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabaseService.signInWithGoogle();
      // The auth state change listener will handle the rest
      return true;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      _errorMessage = 'Google sign in failed: ${e.toString()}';
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
      // Auth state change listener will handle the rest
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
    
    // Save onboarding completion to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
