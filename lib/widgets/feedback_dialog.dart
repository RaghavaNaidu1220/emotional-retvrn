import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/feedback_service.dart';
import '../core/config/theme_config.dart';

class FeedbackDialog extends StatefulWidget {
  final String type;
  final String title;

  const FeedbackDialog({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  final _expectedController = TextEditingController();
  final _actualController = TextEditingController();
  final _useCaseController = TextEditingController();
  
  String _priority = 'medium';
  bool _isSubmitting = false;
  
  final FeedbackService _feedbackService = FeedbackService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.type == 'bug' 
                    ? [ThemeConfig.primaryOrange, ThemeConfig.primaryRed]
                    : [ThemeConfig.primaryBlue, ThemeConfig.primaryPurple],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.type == 'bug' ? Icons.bug_report : Icons.lightbulb,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: widget.type == 'bug' 
                          ? 'Brief description of the issue'
                          : 'Feature name or summary',
                        required: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: widget.type == 'bug'
                          ? 'Detailed description of the bug'
                          : 'Detailed description of the feature',
                        maxLines: 3,
                        required: true,
                      ),
                      
                      if (widget.type == 'bug') ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _stepsController,
                          label: 'Steps to Reproduce',
                          hint: '1. Go to...\n2. Click on...\n3. See error',
                          maxLines: 3,
                          required: true,
                        ),
                        
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _expectedController,
                          label: 'Expected Behavior',
                          hint: 'What should happen?',
                          maxLines: 2,
                        ),
                        
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _actualController,
                          label: 'Actual Behavior',
                          hint: 'What actually happened?',
                          maxLines: 2,
                        ),
                      ],
                      
                      if (widget.type == 'feature') ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _useCaseController,
                          label: 'Use Case',
                          hint: 'How would this feature be used?',
                          maxLines: 2,
                        ),
                        
                        const SizedBox(height: 16),
                        Text(
                          'Priority',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'high', child: Text('High')),
                          ],
                          onChanged: (value) => setState(() => _priority = value!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: widget.type == 'bug' 
                          ? ThemeConfig.primaryOrange 
                          : ThemeConfig.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: required
            ? (value) => value?.isEmpty == true ? 'This field is required' : null
            : null,
        ),
      ],
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final deviceInfo = await _getDeviceInfo();
      
      if (widget.type == 'bug') {
        await _feedbackService.submitBugReport(
          title: _titleController.text,
          description: _descriptionController.text,
          stepsToReproduce: _stepsController.text,
          expectedBehavior: _expectedController.text.isEmpty ? null : _expectedController.text,
          actualBehavior: _actualController.text.isEmpty ? null : _actualController.text,
          deviceInfo: deviceInfo,
        );
      } else {
        await _feedbackService.submitFeatureRequest(
          title: _titleController.text,
          description: _descriptionController.text,
          useCase: _useCaseController.text.isEmpty ? null : _useCaseController.text,
          priority: _priority,
        );
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.type == 'bug' ? 'Bug report' : 'Feature request'} submitted successfully!'),
            backgroundColor: ThemeConfig.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting ${widget.type}: $e'),
            backgroundColor: ThemeConfig.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      return {
        'app_version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
        'package_name': packageInfo.packageName,
        'platform': Theme.of(context).platform.name,
      };
    } catch (e) {
      return {'error': 'Could not get device info: $e'};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    _expectedController.dispose();
    _actualController.dispose();
    _useCaseController.dispose();
    super.dispose();
  }
}
