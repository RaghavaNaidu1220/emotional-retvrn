import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';
import '../../services/simple_voice_service.dart';
import '../../services/simple_analyzer_service.dart';

class SimpleVoiceJournal extends StatefulWidget {
  const SimpleVoiceJournal({super.key});

  @override
  State<SimpleVoiceJournal> createState() => _SimpleVoiceJournalState();
}

class _SimpleVoiceJournalState extends State<SimpleVoiceJournal> {
  final SimpleVoiceService _voiceService = SimpleVoiceService();
  final SimpleAnalyzerService _analyzer = SimpleAnalyzerService();
  
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String? _extractedText;
  Map<String, dynamic>? _analysis;

  Future<void> _startVoiceRecording() async {
    setState(() {
      _isRecording = true;
      _extractedText = null;
      _analysis = null;
    });

    try {
      final text = await _voiceService.getVoiceText();
      
      if (text != null && text.isNotEmpty) {
        setState(() {
          _extractedText = text;
          _isRecording = false;
          _isAnalyzing = true;
        });
        
        // Analyze the text
        final analysis = await _analyzer.analyzeText(text);
        
        setState(() {
          _analysis = analysis;
          _isAnalyzing = false;
        });
        
      } else {
        setState(() {
          _isRecording = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No speech detected. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isAnalyzing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveJournal() async {
    if (_extractedText == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    
    try {
      final userId = authProvider.currentUser?.id ?? 'demo_user_123';
      final journal = JournalModel(
        userId: userId,
        content: _extractedText!,
        transcript: _extractedText,
        createdAt: DateTime.now(),
      );

      await journalProvider.createJournal(journal);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear for next entry
      setState(() {
        _extractedText = null;
        _analysis = null;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text('🎙️ Voice Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Voice Recording Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _isRecording ? '🎙️ Listening...' : '🎤 Tap to Record',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRecording 
                        ? 'Speak clearly and loudly' 
                        : 'Record your thoughts and feelings',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Record Button
                  GestureDetector(
                    onTap: _isRecording ? null : _startVoiceRecording,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : Colors.blue)
                                .withOpacity(0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.mic : Icons.mic_none,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  if (_isAnalyzing) ...[
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Analyzing your voice...'),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Extracted Text
            if (_extractedText != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📝 Your Voice:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _extractedText!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Analysis Results
            if (_analysis != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧠 AI Analysis:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    _buildAnalysisRow('Emotion', _analysis!['emotion']),
                    _buildAnalysisRow('Mood', _analysis!['mood']),
                    
                    const SizedBox(height: 10),
                    const Text(
                      'Insights:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_analysis!['insights']),
                    
                    const SizedBox(height: 10),
                    const Text(
                      'Suggestions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_analysis!['suggestions']),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveJournal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Save Journal Entry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
