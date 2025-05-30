import 'package:flutter/material.dart';
import '../models/practice_model.dart';

class PracticeProvider extends ChangeNotifier {
  List<PracticeModel> _practices = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<PracticeModel> get practices => _practices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadPractices() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Use sample data from PracticeModel
      _practices = PracticeModel.getSamplePractices();
      
      debugPrint('Loaded ${_practices.length} practices');
    } catch (e) {
      debugPrint('Error loading practices: $e');
      _setError('Failed to load practices: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
