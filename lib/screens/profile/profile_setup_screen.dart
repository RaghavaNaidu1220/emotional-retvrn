import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/spiral_dynamics_model.dart';
import '../dashboard/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _ageController = TextEditingController();
  String _selectedSpiralStage = 'beige';
  
  bool _isLoading = false;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (details.stepIndex > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(details.stepIndex == 1 ? 'Complete Setup' : 'Next'),
                  ),
                ],
              ),
            );
          },
          onStepContinue: () {
            if (_currentStep == 0) {
              if (_validateAge()) {
                setState(() {
                  _currentStep = 1;
                });
              }
            } else if (_currentStep == 1) {
              _completeSetup();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          steps: [
            Step(
              title: const Text('Basic Information'),
              content: _buildAgeStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Spiral Dynamics Stage'),
              content: _buildSpiralStageStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us a bit about yourself',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'This information helps us provide better personalized insights.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _ageController,
          decoration: const InputDecoration(
            labelText: 'Age',
            hintText: 'Enter your age',
            prefixIcon: Icon(Icons.cake),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            final age = int.tryParse(value);
            if (age == null || age < 13 || age > 120) {
              return 'Please enter a valid age (13-120)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSpiralStageStep() {
    final stages = SpiralDynamicsModel.getAllStages();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Current Spiral Dynamics Stage',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose the stage that best represents your current worldview and values. Don\'t worry, you can change this later.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        ...stages.map((stage) => _buildStageOption(stage)).toList(),
      ],
    );
  }

  Widget _buildStageOption(SpiralDynamicsModel stage) {
    final isSelected = _selectedSpiralStage == stage.stage;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSpiralStage = stage.stage;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? Color(stage.colorValue)
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
                ? Color(stage.colorValue).withOpacity(0.1)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(stage.colorValue),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Color(stage.colorValue) : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Color(stage.colorValue),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateAge() {
    if (_ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your age'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 13 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid age (13-120)'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    return true;
  }

  Future<void> _completeSetup() async {
    if (!_validateAge()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentProfile = authProvider.userProfile;
      
      if (currentProfile == null) {
        throw Exception('User profile not found');
      }

      final updatedProfile = currentProfile.copyWith(
        age: int.parse(_ageController.text),
        spiralStage: _selectedSpiralStage,
      );

      final success = await authProvider.updateProfile(updatedProfile);

      if (!mounted) return;

      if (success) {
        await authProvider.completeOnboarding();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to complete setup'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
