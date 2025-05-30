import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/spiral_dynamics_model.dart';
import '../dashboard/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  String _selectedSpiralStage = 'beige';
  int _currentStep = 0;

  final List<SpiralDynamicsModel> _spiralStages = SpiralDynamicsModel.getAllStages();

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    
    if (user == null) return;

    final updatedUser = user.copyWith(
      age: int.tryParse(_ageController.text),
      spiralStage: _selectedSpiralStage,
    );

    final success = await authProvider.updateProfile(updatedUser);
    
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            return Row(
              children: [
                if (details.stepIndex < 2)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _completeSetup,
                    child: const Text('Complete Setup'),
                  ),
                const SizedBox(width: 8),
                if (details.stepIndex > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Basic Information'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age (Optional)',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final age = int.tryParse(value);
                        if (age == null || age < 13 || age > 120) {
                          return 'Please enter a valid age';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Spiral Dynamics Assessment'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the stage that best describes your current worldview:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._spiralStages.map((stage) => RadioListTile<String>(
                    title: Text(stage.name),
                    subtitle: Text(stage.description),
                    value: stage.stage,
                    groupValue: _selectedSpiralStage,
                    onChanged: (value) {
                      setState(() {
                        _selectedSpiralStage = value!;
                      });
                    },
                    secondary: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(stage.colorValue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )).toList(),
                ],
              ),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Review & Complete'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review your information:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_ageController.text.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.cake),
                      title: const Text('Age'),
                      subtitle: Text('${_ageController.text} years old'),
                    ),
                  ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(_spiralStages
                            .firstWhere((s) => s.stage == _selectedSpiralStage)
                            .colorValue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    title: const Text('Spiral Dynamics Stage'),
                    subtitle: Text(_spiralStages
                        .firstWhere((s) => s.stage == _selectedSpiralStage)
                        .name),
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }
}
