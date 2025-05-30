import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:journal_app/config/theme_config.dart';
import 'package:journal_app/models/journal_entry.dart';
import 'package:journal_app/services/ai_service.dart';
import 'package:journal_app/services/database_service.dart';
import 'package:uuid/uuid.dart';

class EnhancedJournalScreen extends StatefulWidget {
  final JournalEntry? entry;

  const EnhancedJournalScreen({Key? key, this.entry}) : super(key: key);

  @override
  _EnhancedJournalScreenState createState() => _EnhancedJournalScreenState();
}

class _EnhancedJournalScreenState extends State<EnhancedJournalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isLoadingAI = false;
  String? _aiQuestion;
  String? _followUpQuestion;
  String? _aiInsight;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _bodyController.text = widget.entry!.body;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _generateAIContent() async {
    setState(() {
      _isLoadingAI = true;
      _aiQuestion = null;
      _followUpQuestion = null;
      _aiInsight = null;
    });

    try {
      final aiResponse = await AIService.getAIResponse(_bodyController.text);

      setState(() {
        _aiQuestion = aiResponse['question'];
        _followUpQuestion = aiResponse['follow_up'];
        _aiInsight = aiResponse['insight'];
      });
    } catch (e) {
      // Handle errors appropriately, perhaps show a snackbar
      print("Error generating AI content: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate AI content. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoadingAI = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: _bodyController.text.isNotEmpty ? _generateAIContent : null,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_titleController.text.isNotEmpty || _bodyController.text.isNotEmpty) {
                final entry = JournalEntry(
                  id: widget.entry?.id ?? const Uuid().v4(),
                  title: _titleController.text,
                  body: _bodyController.text,
                  createdAt: widget.entry?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (widget.entry == null) {
                  await DatabaseService.createEntry(entry);
                } else {
                  await DatabaseService.updateEntry(entry);
                }
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title or body cannot be empty.')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts here...',
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1000),
                ],
              ),

                    // AI Insights and Questions
                    if (_aiQuestion != null || _followUpQuestion != null || _aiInsight != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ThemeConfig.primaryPurple.withOpacity(0.1),
                              ThemeConfig.primaryBlue.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: ThemeConfig.primaryPurple.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ThemeConfig.primaryPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.psychology,
                                    color: ThemeConfig.primaryPurple,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'AI Reflection Guide',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ThemeConfig.primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            if (_isLoadingAI) ...[
                              const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ] else ...[
                              if (_aiInsight != null) ...[
                                Text(
                                  'Insight:',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _aiInsight!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: ThemeConfig.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              
                              if (_aiQuestion != null) ...[
                                Text(
                                  'Question to consider:',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _aiQuestion!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              
                              if (_followUpQuestion != null) ...[
                                Text(
                                  'Follow-up:',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _followUpQuestion!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
            ],
          ),
        ),
      ),
    );
  }
}
