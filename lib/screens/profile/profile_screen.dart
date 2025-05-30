import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/spiral_dynamics_model.dart';
import '../auth/auth_screen.dart';
import '../../core/config/theme_config.dart';
import '../help/help_support_screen.dart';
import '../about/about_screen.dart';
import '../spiral_assessment/spiral_assessment_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ThemeProvider, JournalProvider>(
      builder: (context, authProvider, themeProvider, journalProvider, child) {
        final user = authProvider.userProfile;
        final spiralStage = SpiralDynamicsModel.getStageByName(user?.spiralStage ?? 'beige');
        
        // Get first letter safely
        String firstLetter = 'U';
        if (user?.name != null && user!.name.isNotEmpty) {
          firstLetter = user.name[0].toUpperCase();
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                onPressed: themeProvider.toggleTheme,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            firstLetter,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'User',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Current Spiral Stage
                if (spiralStage != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Spiral Dynamics Stage',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(spiralStage.colorValue).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(spiralStage.colorValue),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(spiralStage.colorValue),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        spiralStage.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        spiralStage.description,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Profile Information
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cake),
                        title: const Text('Age'),
                        subtitle: Text(user?.age?.toString() ?? 'Not specified'),
                        trailing: const Icon(Icons.edit),
                        onTap: () {
                          _showEditAgeDialog(context, authProvider);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.psychology),
                        title: const Text('Spiral Stage'),
                        subtitle: Text(spiralStage?.name ?? 'Unknown'),
                        trailing: const Icon(Icons.edit),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SpiralAssessmentScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Settings
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        trailing: Switch(
                          value: true, // TODO: Implement notification settings
                          onChanged: (value) {
                            // TODO: Handle notification toggle
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          themeProvider.themeMode == ThemeMode.dark 
                              ? Icons.dark_mode 
                              : Icons.light_mode,
                        ),
                        title: const Text('Theme'),
                        subtitle: Text(
                          themeProvider.themeMode == ThemeMode.dark 
                              ? 'Dark Mode' 
                              : 'Light Mode',
                        ),
                        trailing: Switch(
                          value: themeProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) => themeProvider.toggleTheme(),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('About'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AboutScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Clear journal data
                      journalProvider.clearData();
                      
                      // Sign out
                      await authProvider.signOut();
                      
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditAgeDialog(BuildContext context, AuthProvider authProvider) {
    final TextEditingController ageController = TextEditingController();
    final user = authProvider.userProfile;
    
    if (user?.age != null) {
      ageController.text = user!.age.toString();
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Age'),
        content: TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Age',
            hintText: 'Enter your age',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final age = int.tryParse(ageController.text);
              if (age != null && age > 0 && age < 150) {
                final updatedUser = user!.copyWith(age: age);
                final success = await authProvider.updateProfile(updatedUser);
                
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Age updated successfully'),
                      backgroundColor: ThemeConfig.primaryGreen,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid age'),
                    backgroundColor: ThemeConfig.primaryRed,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
