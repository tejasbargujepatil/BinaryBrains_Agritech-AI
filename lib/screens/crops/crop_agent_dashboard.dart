import 'package:flutter/material.dart';
import 'package:krishi_mitra/l10n/app_localizations.dart';
import '../../config/app_theme.dart';
import '../../widgets/charts.dart';
import '../../services/agent_service.dart';
import '../../models/agent_plan_model.dart';
import '../../services/crop_service.dart';
import '../../services/weather_service.dart';
import '../../services/soil_service.dart';
import 'dart:convert';

class CropAgentDashboard extends StatefulWidget {
  final String cropId;

  const CropAgentDashboard({super.key, required this.cropId});

  @override
  State<CropAgentDashboard> createState() => _CropAgentDashboardState();
}

class _CropAgentDashboardState extends State<CropAgentDashboard> {
  AgentPlanModel? _agentPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgentPlan();
  }

  Future<void> _loadAgentPlan() async {
    // 1. Try to load cached plan first for immediate display
    try {
      final cachedPlan = await AgentService.getCachedSmartPlan(widget.cropId);
      if (cachedPlan != null && mounted) {
        setState(() {
          _agentPlan = cachedPlan;
          // Don't set isLoading false yet if we want to show a spinner indicating refresh, 
          // or set it false and let the refresh happen silently.
          // Let's set it false to show data, and maybe show a small loading indicator elsewhere.
          _isLoading = false; 
        });
      }
    } catch (e) {
      print('DEBUG: Cache load error: $e');
    }

    if (_agentPlan == null) {
      setState(() => _isLoading = true);
    }
    
    try {
      // 2. Fetch Fresh Data (Background Refresh)
      final cropResult = await CropService.getCropDetails(widget.cropId);
      if (!cropResult['success']) {
        throw Exception(cropResult['error']);
      }
      final cropName = cropResult['crop'].cropName;
      final location = "Pune, Maharashtra"; // Fallback

      final weatherResult = await WeatherService.getUserWeather();
      final soilResult = await SoilService.getUserSoilData();

      final result = await AgentService.generateSmartPlan(
        cropName: cropName,
        location: location,
        weatherData: weatherResult['success'] ? weatherResult['weather'].toJson() : {},
        soilData: soilResult['success'] ? soilResult['soil'].toJson() : {},
        cropId: widget.cropId, // Pass ID for caching
      );

      if (result['success']) {
        if (mounted) {
          setState(() {
            _agentPlan = result['plan'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      if (mounted) {
        // Only show error screen if we have absolutely nothing
        if (_agentPlan == null) {
           setState(() => _isLoading = false);
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI Generation Failed: ${e.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        } else {
           print("DEBUG: Background refresh failed: $e");
        }
      }
    }
  }


  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required Widget content,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.mediumRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (iconColor ?? AppTheme.primaryGreen).withOpacity(0.2),
                  (iconColor ?? AppTheme.primaryGreen).withOpacity(0.1),
                ],
              ),
              borderRadius: AppTheme.smallRadius,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
          ],
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern gradient app bar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.cropDashboard,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadAgentPlan,
              ),
            ],
          ),

          // Content
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              ),
            )
          else if (_agentPlan == null)
            SliverFillRemaining(
              child: Center(child: Text(l10n.noDataAvailable)),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppTheme.spacingMd),

                // Section 1: Suitability
                _buildModernSection(
                  title: l10n.suitability,
                  icon: Icons.check_circle_outline,
                  iconColor: AppTheme.success,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Score indicator
                      LinearProgressBar(
                        label: 'Suitability Score',
                        percentage: double.tryParse(
                          _agentPlan!.suitability.suitabilityScore.replaceAll(RegExp(r'[^0-9.]'), ''),
                        ) ?? 0.0,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildInfoRow(
                        'Soil Validation',
                        _agentPlan!.suitability.soilValidation,
                        icon: Icons.landscape,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      const Text(
                        'Recommendations:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      ..._agentPlan!.suitability.recommendations.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.arrow_right,
                                size: 20,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 4),
                              Expanded(child: Text(r)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section 2: Government Schemes
                _buildModernSection(
                  title: l10n.governmentSchemes,
                  icon: Icons.account_balance,
                  iconColor: const Color(0xFF2196F3),
                  content: Column(
                    children: _agentPlan!.governmentSchemes.map((scheme) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.veryLightGreen,
                          borderRadius: AppTheme.smallRadius,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scheme.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scheme.description,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Section 3: Sowing Plan
                _buildModernSection(
                  title: l10n.sowingPlan,
                  icon: Icons.calendar_month,
                  iconColor: const Color(0xFFFF9800),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Best Sowing Window',
                        _agentPlan!.sowingPlan.bestSowingWindow,
                        icon: Icons.event,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      _buildInfoRow(
                        'Weather Considerations',
                        _agentPlan!.sowingPlan.weatherConsiderations,
                        icon: Icons.wb_sunny,
                      ),
                    ],
                  ),
                ),

                // Section 4: Fertilization
                _buildModernSection(
                  title: l10n.fertilization,
                  icon: Icons.eco,
                  iconColor: const Color(0xFF4CAF50),
                  content: Column(
                    children: _agentPlan!.fertilization.schedule.map((f) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.veryLightGreen),
                          borderRadius: AppTheme.smallRadius,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.stage,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildInfoRow('Fertilizer', f.fertilizer),
                            _buildInfoRow('Quantity', f.quantity),
                            _buildInfoRow('Method', f.method),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Section 5: Irrigation
                _buildModernSection(
                  title: l10n.irrigationSchedule,
                  icon: Icons.water_drop,
                  iconColor: const Color(0xFF03A9F4),
                  content: Column(
                    children: _agentPlan!.irrigation.schedule.map((i) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: AppTheme.smallRadius,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.water, color: Color(0xFF03A9F4)),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.stage,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${i.frequency} - ${i.amount}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Section 6: Disease Probability
                _buildModernSection(
                  title: l10n.diseaseProbability,
                  icon: Icons.bug_report,
                  iconColor: const Color(0xFFF44336),
                  content: Column(
                    children: _agentPlan!.disease.timeline.map((d) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: AppTheme.smallRadius,
                          border: Border.all(color: const Color(0xFFEF9A9A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber, color: Color(0xFFF44336), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    d.diseaseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFC62828),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            _buildInfoRow('Stage', d.stage),
                            _buildInfoRow('Probability', d.probability),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Section 7: Photo Upload
                _buildModernSection(
                  title: l10n.uploadPhoto,
                  icon: Icons.camera_alt,
                  iconColor: const Color(0xFF9C27B0),
                  content: Column(
                    children: [
                      const Text(
                        'Upload crop photos for AI-powered disease detection',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement photo upload
                        },
                        icon: const Icon(Icons.add_a_photo),
                        label: Text(l10n.photoForDisease),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section 8: Harvest
                _buildModernSection(
                  title: l10n.harvestTiming,
                  icon: Icons.grass,
                  iconColor: const Color(0xFFFFEB3B),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Expected Harvest Date',
                        _agentPlan!.harvest.expectedHarvestDate,
                        icon: Icons.event_available,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      _buildInfoRow(
                        'Yield Prediction',
                        _agentPlan!.harvest.yieldPrediction,
                        icon: Icons.analytics,
                      ),
                    ],
                  ),
                ),

                // Section 9: Residue
                _buildModernSection(
                  title: l10n.cropResidue,
                  icon: Icons.recycling,
                  iconColor: const Color(0xFF009688),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _agentPlan!.residue.utilizationMethods.map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 18, color: Color(0xFF009688)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(m)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Section 10: Storage
                _buildModernSection(
                  title: l10n.storageGuidance,
                  icon: Icons.warehouse,
                  iconColor: const Color(0xFF795548),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Method', _agentPlan!.storage.storageMethod, icon: Icons.inventory),
                      _buildInfoRow('Duration', _agentPlan!.storage.storageDuration, icon: Icons.schedule),
                      _buildInfoRow('Price Prediction', _agentPlan!.storage.pricePrediction, icon: Icons.currency_rupee),
                    ],
                  ),
                ),

                // Section 11: Value-Added Products
                _buildModernSection(
                  title: l10n.valueAddedProducts,
                  icon: Icons.add_business,
                  iconColor: const Color(0xFFE91E63),
                  content: Column(
                    children: _agentPlan!.valueAddedProducts.map((p) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE91E63).withOpacity(0.1),
                              const Color(0xFFE91E63).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: AppTheme.smallRadius,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(p.description, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Section 12: Direct Selling
                _buildModernSection(
                  title: l10n.directSelling,
                  icon: Icons.storefront,
                  iconColor: const Color(0xFFFF5722),
                  content: Column(
                    children: _agentPlan!.directSelling.platforms.map((p) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: AppTheme.smallRadius,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_cart, color: Color(0xFFFF5722)),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(p.description, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Section 13: Allied Business
                _buildModernSection(
                  title: l10n.alliedBusiness,
                  icon: Icons.business_center,
                  iconColor: const Color(0xFF673AB7),
                  content: Column(
                    children: _agentPlan!.alliedBusinessIdeas.map((b) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1C4E9)),
                          borderRadius: AppTheme.smallRadius,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(b.description, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.currency_rupee, size: 16, color: Color(0xFF673AB7)),
                                Text(
                                  'Investment: ${b.investment}',
                                  style: const TextStyle(
                                    color: Color(0xFF673AB7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),


                const SizedBox(height: AppTheme.spacingXl),
              ]),
            ),
        ],
      ),
    );
  }
}
