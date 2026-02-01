import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/agent_dashboard_service.dart';

/// Disease Detection Screen - Upload image and get AI diagnosis
class DiseaseDetectionScreen extends StatefulWidget {
  final int cropId;
  final String cropName;

  const DiseaseDetectionScreen({
    Key? key,
    required this.cropId,
    required this.cropName,
  }) : super(key: key);

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final _symptomsController = TextEditingController();
  File? _selectedImage;
  bool _detecting = false;
  Map<String, dynamic>? _diagnosis;
  List<Map<String, dynamic>> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await AgentDashboardService.getDiseaseHistory(widget.cropId);
      setState(() {
        _history = history;
        _loadingHistory = false;
      });
    } catch (e) {
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _detectDisease() async {
    if (_symptomsController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide symptoms or upload an image')),
      );
      return;
    }

    setState(() {
      _detecting = true;
      _diagnosis = null;
    });

    try {
      // In real app, upload image to cloud storage first and get URL
      // For now, we'll just pass image info in symptoms
      String symptoms = _symptomsController.text.trim();
      if (_selectedImage != null) {
        symptoms += '\n[Image uploaded: ${_selectedImage!.path.split('/').last}]';
      }

      final result = await AgentDashboardService.detectDisease(
        cropId: widget.cropId,
        symptoms: symptoms,
        imageUrl: _selectedImage != null ? 'local://${_selectedImage!.path}' : null,
      );

      setState(() {
        _diagnosis = result['diagnosis'];
        _detecting = false;
      });

      // Reload history
      _loadHistory();
    } catch (e) {
      setState(() => _detecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔬 Disease Detection'),
        subtitle: Text(widget.cropName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Input Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '📸 Upload Image or Describe Symptoms',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Image selection
                  if (_selectedImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                            onPressed: () => setState(() => _selectedImage = null),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Symptoms input
                  TextField(
                    controller: _symptomsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Describe Symptoms',
                      hintText: 'e.g., Yellow spots on leaves, wilting, brown edges...',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    icon: _detecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.search),
                    label: Text(_detecting ? 'Analyzing...' : 'Detect Disease'),
                    onPressed: _detecting ? null : _detectDisease,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Diagnosis Result
          if (_diagnosis != null) ...[
            const SizedBox(height: 16),
            Card(
              color: _diagnosis!['severity'] == 'High' ? Colors.red[50] : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bug_report,
                          color: _diagnosis!['severity'] == 'High' ? Colors.red : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _diagnosis!['disease_name'] ?? 'Unknown Disease',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Confidence: ${_diagnosis!['confidence_score']}%',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _diagnosis!['severity'] == 'High' ? Colors.red : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _diagnosis!['severity'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Immediate Actions
                    if (_diagnosis!['immediate_actions'] != null) ...[
                      const Text(
                        '⚡ Immediate Actions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...(_diagnosis!['immediate_actions'] as List).map((action) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(action)),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],

                    // Chemical Treatment
                    if (_diagnosis!['chemical_treatment'] != null) ...[
                      const Text(
                        '💊 Chemical Treatment',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildTreatmentInfo(_diagnosis!['chemical_treatment']),
                      const SizedBox(height: 16),
                    ],

                    // Organic Alternatives
                    if (_diagnosis!['organic_alternatives'] != null) ...[
                      const Text(
                        '🌿 Organic Alternatives',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...(_diagnosis!['organic_alternatives'] as List).map((alt) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.eco, color: Colors.green),
                            title: Text(alt['treatment'] ?? ''),
                            subtitle: Text('Effectiveness: ${alt['effectiveness'] ?? 'N/A'}'),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),
          ],

          // Detection History
          const SizedBox(height: 24),
          const Text(
            '📜 Detection History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (_loadingHistory)
            const Center(child: CircularProgressIndicator())
          else if (_history.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No previous detections',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ..._history.map((detection) {
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.bug_report,
                    color: detection['severity'] == 'High' ? Colors.red : Colors.orange,
                  ),
                  title: Text(detection['disease_name'] ?? 'Unknown'),
                  subtitle: Text(detection['detected_at'] ?? ''),
                  trailing: Text('${detection['confidence_score']}%'),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTreatmentInfo(Map<String, dynamic> treatment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Product', treatment['recommended_fungicide'] ?? treatment['product'] ?? 'N/A'),
          _buildInfoRow('Dosage', treatment['dosage'] ?? 'N/A'),
          if (treatment['frequency'] != null) _buildInfoRow('Frequency', treatment['frequency']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
