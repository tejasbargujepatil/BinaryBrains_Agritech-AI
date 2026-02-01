import 'package:flutter/material.dart';
import 'package:krishi_mitra/l10n/app_localizations.dart';
import '../../services/agent_dashboard_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _alerts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final alerts = await AgentDashboardService.getAlerts();
      setState(() {
        _alerts = alerts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alertsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
        ],
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
                        onPressed: _loadAlerts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _alerts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.noAlerts,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'All your crops are on track! 🌾',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAlerts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _alerts.length,
                        itemBuilder: (context, index) {
                          final alert = _alerts[index];
                          return _buildAlertCard(alert);
                        },
                      ),
                    ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final priority = alert['priority'] ?? 'medium';
    final type = alert['type'] ?? 'general';

    Color borderColor;
    Color backgroundColor;
    IconData icon;

    switch (priority) {
      case 'critical':
        borderColor = Colors.red;
        backgroundColor = Colors.red[50]!;
        icon = Icons.warning;
        break;
      case 'high':
        borderColor = Colors.orange;
        backgroundColor = Colors.orange[50]!;
        icon = Icons.priority_high;
        break;
      default:
        borderColor = Colors.blue;
        backgroundColor = Colors.blue[50]!;
        icon = Icons.info_outline;
    }

    // Icon based on type
    if (type == 'irrigation') icon = Icons.water_drop;
    if (type == 'disease') icon = Icons.bug_report;
    if (type == 'fertilization') icon = Icons.eco;
    if (type == 'harvest') icon = Icons.agriculture;
    if (type == 'price') icon = Icons.trending_up;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          title: Text(
            alert['message'] ?? 'Alert',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (alert['crop'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.agriculture, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Crop: ${alert['crop']}'),
                  ],
                ),
              ],
              if (alert['action_required'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          alert['action_required'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (alert['created_at'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  alert['created_at'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          trailing: priority == 'critical'
              ? const Icon(Icons.priority_high, color: Colors.red, size: 32)
              : null,
        ),
      ),
    );
  }
}

