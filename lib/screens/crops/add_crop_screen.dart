import 'package:flutter/material.dart';
import 'package:krishi_mitra/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../services/crop_service.dart';
import '../../config/constants.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _landAreaController = TextEditingController();
  final _varietyController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedIrrigationType = AppConstants.irrigationTypes[0];
  bool _isLoading = false;

  @override
  void dispose() {
    _cropNameController.dispose();
    _landAreaController.dispose();
    _varietyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _addCrop() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select sowing date'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await CropService.addCrop(
      cropName: _cropNameController.text,
      sowingDate: _selectedDate!,
      landArea: double.parse(_landAreaController.text),
      irrigationType: _selectedIrrigationType,
      cropVariety: _varietyController.text.isNotEmpty
          ? _varietyController.text
          : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.successCropAdded),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.mediumRadius),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(result['error'] ?? 'Failed to add crop')),
            ],
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.mediumRadius),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.addNewCrop),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    gradient: AppTheme.lightGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 48,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              
              Center(
                child: Text(
                  'Add New Crop',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Center(
                child: Text(
                  'Fill in the details below to track your crop',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXl),

              // Crop name
              _buildInputCard(
                child: TextFormField(
                  controller: _cropNameController,
                  decoration: InputDecoration(
                    labelText: l10n.cropName,
                    hintText: 'e.g., Wheat, Cotton, Rice',
                    prefixIcon: const Icon(Icons.agriculture, color: AppTheme.primaryGreen),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Sowing date
              _buildInputCard(
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: AppTheme.mediumRadius,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.sowingDate,
                      prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat(AppConstants.dateFormat).format(_selectedDate!)
                          : l10n.selectDate,
                      style: TextStyle(
                        color: _selectedDate != null
                            ? AppTheme.textPrimary
                            : AppTheme.textHint,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Land area
              _buildInputCard(
                child: TextFormField(
                  controller: _landAreaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${l10n.landArea} (${l10n.acres})',
                    hintText: 'e.g., 2.5',
                    prefixIcon: const Icon(Icons.landscape, color: AppTheme.primaryGreen),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Irrigation type
              _buildInputCard(
                child: DropdownButtonFormField<String>(
                  value: _selectedIrrigationType,
                  decoration: InputDecoration(
                    labelText: l10n.irrigationType,
                    prefixIcon: const Icon(Icons.water_drop, color: AppTheme.primaryGreen),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  items: AppConstants.irrigationTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedIrrigationType = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Crop variety (optional)
              _buildInputCard(
                child: TextFormField(
                  controller: _varietyController,
                  decoration: InputDecoration(
                    labelText: '${l10n.cropVariety} ${l10n.optional}',
                    hintText: 'e.g., HD-2967, BT Cotton',
                    prefixIcon: const Icon(Icons.grass, color: AppTheme.primaryGreen),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXl),

              // Submit button with gradient
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.mediumRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addCrop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.mediumRadius,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline),
                            const SizedBox(width: 8),
                            Text(
                              l10n.submit,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.mediumRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: child,
    );
  }
}
