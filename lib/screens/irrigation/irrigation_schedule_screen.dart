import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/agent_dashboard_service.dart';

/// Irrigation Schedule Screen - Shows watering timeline from backend
class IrrigationScheduleScreen extends StatefulWidget {
  final int cropId;
  final String cropName;

  const IrrigationScheduleScreen({
    Key? key,
    required this.cropId,
    required this.cropName,
  }) : super(key: key);

  @override
  State<IrrigationScheduleScreen> createState() => _IrrigationScheduleScreenState();
}

class _IrrigationScheduleScreenState extends State<IrrigationScheduleScreen> {
  bool _loading = true;
  Map<String, dynamic>? _schedule;
  String? _error;
  final _moistureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  @override
  void dispose() {
    _moistureController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await AgentDashboardService.getIrrigationSchedule(widget.cropId);
      setState(() {
        _schedule = data['schedule'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateMoisture() async {
    final moisture = double.tryParse(_moistureController.text);
    if (moisture == null || moisture < 0 || moisture > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid moisture (0-100)')),
      );
      return;
    }

    try {
      setState(() => _loading = true);
      final data = await AgentDashboardService.updateSoilMoisture(
        cropId: widget.cropId,
        soilMoisture: moisture,
      );
      setState(() {
        _schedule = data['schedule'];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Schedule updated based on new moisture level!'),
          backgroundColor: Colors.green,
        ),
      );
      _moistureController.clear();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('💧 Irrigation Schedule'),
        subtitle: Text(widget.cropName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSchedule,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSchedule,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Next Irrigation Card
                      if (_schedule?['next_irrigation'] != null)
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.water_drop, color: Colors.blue, size: 32),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Next Irrigation',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _schedule!['next_irrigation']['date'] ?? 'TBD',
                                            style: const TextStyle(fontSize: 16, color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow('Time', _schedule!['next_irrigation']['time'] ?? 'TBD'),
                                _buildInfoRow('Water Amount', '${_schedule!['next_irrigation']['water_amount_mm']} mm'),
                                if (_schedule!['next_irrigation']['reason'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _schedule!['next_irrigation']['reason'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Update Soil Moisture Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🌱 Update Soil Moisture',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'AI will auto-adjust schedule based on new moisture level',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _moistureController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Soil Moisture %',
                                        hintText: '0-100',
                                        border: OutlineInputBorder(),
                                        suffixText: '%',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: _updateMoisture,
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 7-Day Schedule
                      if (_schedule?['next_7_days_schedule'] != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '📅 7-Day Schedule',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                ...(_schedule!['next_7_days_schedule'] as List).map((day) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: day['irrigate'] ? Colors.blue : Colors.grey[300],
                                      child: Icon(
                                        day['irrigate'] ? Icons.water_drop : Icons.block,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(day['date']),
                                    subtitle: Text(day['reason'] ?? ''),
                                    trailing: day['irrigate']
                                        ? Text('${day['water_amount_mm']} mm', style: const TextStyle(fontWeight: FontWeight.bold))
                                        : null,
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Water Saving Tips
                      if (_schedule?['water_saving_tips'] != null)
                        Card(
                          color: Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.lightbulb, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      'Water Saving Tips',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...(_schedule!['water_saving_tips'] as List).map((tip) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ', style: TextStyle(fontSize: 16)),
                                        Expanded(child: Text(tip)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
