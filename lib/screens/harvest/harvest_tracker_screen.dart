import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/agent_dashboard_service.dart';

/// Harvest Tracker Screen - Shows predicted harvest date, yield, and selling strategy
class HarvestTrackerScreen extends StatefulWidget {
  final int cropId;
  final String cropName;

  const HarvestTrackerScreen({
    Key? key,
    required this.cropId,
    required this.cropName,
  }) : super(key: key);

  @override
  State<HarvestTrackerScreen> createState() => _HarvestTrackerScreenState();
}

class _HarvestTrackerScreenState extends State<HarvestTrackerScreen> {
  bool _loading = true;
  Map<String, dynamic>? _recommendations;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await AgentDashboardService.getHarvestRecommendations(widget.cropId);
      setState(() {
        _recommendations = data;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌾 Harvest Tracker'),
        subtitle: Text(widget.cropName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
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
                        onPressed: _loadRecommendations,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecommendations,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Harvest Prediction Card
                      if (_recommendations?['harvest_prediction'] != null)
                        _buildHarvestPrediction(_recommendations!['harvest_prediction']),

                      const SizedBox(height: 16),

                      // Price Forecast Card
                      if (_recommendations?['price_prediction'] != null)
                        _buildPriceForecast(_recommendations!['price_prediction']),

                      const SizedBox(height: 16),

                      // Combined Strategy Card
                      if (_recommendations?['combined_strategy'] != null)
                        _buildCombinedStrategy(_recommendations!['combined_strategy']),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHarvestPrediction(Map<String, dynamic> prediction) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.agriculture, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Harvest Prediction',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${prediction['confidence_level']}% Confident',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Harvest Date
            _buildBigStat(
              icon: Icons.calendar_today,
              label: 'Predicted Harvest Date',
              value: prediction['predicted_harvest_date'] ?? 'TBD',
              subtitle: '${prediction['days_remaining'] ?? 'N/A'} days remaining',
            ),

            const SizedBox(height: 16),

            // Yield Prediction
            _buildBigStat(
              icon: Icons.scale,
              label: 'Estimated Yield',
              value: '${prediction['estimated_yield_per_acre'] ?? 'N/A'} quintals/acre',
              subtitle: 'Quality: ${prediction['quality_grade'] ?? 'N/A'}',
            ),

            const SizedBox(height: 16),

            // Pre-harvest Actions
            if (prediction['pre_harvest_actions'] != null) ...[
              const Text(
                '✅ Pre-Harvest Checklist',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(prediction['pre_harvest_actions'] as List).map((action) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text(action['action'] ?? ''),
                    subtitle: Text('Timing: ${action['timing'] ?? ''}'),
                    dense: true,
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceForecast(Map<String, dynamic> forecast) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Price Forecast',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Current Price
            _buildPriceRow(
              'Current Price',
              forecast['current_price_per_quintal'],
              null,
            ),

            const SizedBox(height: 12),

            // Price Predictions
            if (forecast['price_predictions'] != null) ...[
              const Text(
                '📈 Price Trends',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPriceRow(
                '1 Week',
                forecast['price_predictions']['1_week']?['price'],
                forecast['price_predictions']['1_week']?['change_percent'],
              ),
              _buildPriceRow(
                '2 Weeks',
                forecast['price_predictions']['2_weeks']?['price'],
                forecast['price_predictions']['2_weeks']?['change_percent'],
              ),
              _buildPriceRow(
                '1 Month',
                forecast['price_predictions']['1_month']?['price'],
                forecast['price_predictions']['1_month']?['change_percent'],
              ),
            ],

            const SizedBox(height: 16),

            // Selling Strategy
            if (forecast['selling_strategy'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'AI Recommendation',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      forecast['selling_strategy']['recommendation'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (forecast['selling_strategy']['optimal_selling_date'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '📅 Optimal Date: ${forecast['selling_strategy']['optimal_selling_date']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                    if (forecast['selling_strategy']['reasoning'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        forecast['selling_strategy']['reasoning'],
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedStrategy(Map<String, dynamic> strategy) {
    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple, size: 32),
                SizedBox(width: 12),
                Text(
                  'Krishidnya AI Strategy',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              strategy['recommendation'] ?? 'Follow the harvest and price predictions above for optimal results.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (strategy['expected_profit'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expected Profit',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${strategy['expected_profit']}/acre',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBigStat({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String period, dynamic price, dynamic changePercent) {
    final isPriceAvailable = price != null;
    final isPositive = changePercent != null && changePercent > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: const TextStyle(fontSize: 14),
          ),
          Row(
            children: [
              Text(
                isPriceAvailable ? '₹$price' : 'TBD',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (changePercent != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}$changePercent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
