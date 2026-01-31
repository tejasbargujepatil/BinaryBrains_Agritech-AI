import 'package:flutter/material.dart';
import 'package:krishi_mitra/l10n/app_localizations.dart';
import '../../config/app_theme.dart';
import '../../widgets/modern_cards.dart';
import '../../services/crop_service.dart';
import '../../models/crop_model.dart';
import '../../routes/app_routes.dart';

class CropsListScreen extends StatefulWidget {
  const CropsListScreen({super.key});

  @override
  State<CropsListScreen> createState() => _CropsListScreenState();
}

class _CropsListScreenState extends State<CropsListScreen> {
  List<CropModel> _crops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    setState(() => _isLoading = true);

    final result = await CropService.getCrops();
    if (result['success']) {
      setState(() {
        _crops = result['crops'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to load crops'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.myCrops),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCrops,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            )
          : _crops.isEmpty
              ? _buildEmptyState(l10n)
              : RefreshIndicator(
                  onRefresh: _loadCrops,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    itemCount: _crops.length,
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final crop = _crops[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        child: CropCard(
                          cropName: crop.cropName,
                          variety: crop.cropVariety,
                          daysAfterSowing: crop.getDaysSinceSowing(),
                          landArea: crop.landArea,
                          healthStatus: crop.healthStatus,
                          onTap: () {
                            // Navigate to crop agent dashboard for selected crop
                            Navigator.pushNamed(
                              context,
                              '/crop-agent-dashboard',
                              arguments: crop.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-crop').then((_) {
            _loadCrops();
          });
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              decoration: BoxDecoration(
                gradient: AppTheme.lightGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.agriculture_outlined,
                size: 80,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              l10n.noCrops,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              l10n.addYourFirstCrop,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-crop').then((_) {
                  _loadCrops();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Crop'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
