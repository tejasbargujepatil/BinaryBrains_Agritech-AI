import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crop_model.dart';
import '../config/constants.dart';
import '../config/theme.dart';

class CropCard extends StatelessWidget {
  final CropModel crop;
  final VoidCallback onTap;

  const CropCard({super.key, required this.crop, required this.onTap});

  Color _getHealthColor(String health) {
    switch (health.toUpperCase()) {
      case 'EXCELLENT':
        return AppTheme.successGreen;
      case 'GOOD':
        return AppTheme.infoBlue;
      case 'FAIR':
        return AppTheme.warningYellow;
      case 'POOR':
        return AppTheme.dangerRed;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      crop.cropName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getHealthColor(crop.healthStatus),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      crop.healthStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Sown: ${DateFormat(AppConstants.dateFormat).format(crop.sowingDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.grass, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Stage: ${crop.currentStage}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.landscape, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${crop.landArea} acres',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (crop.lastUpdate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Updated: ${DateFormat(AppConstants.dateTimeFormat).format(crop.lastUpdate!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
