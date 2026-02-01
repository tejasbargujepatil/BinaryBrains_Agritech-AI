/// Comprehensive Agent Plan Model - All 14 sections
class AgentPlanModel {
  final String cropId;
  final SuitabilitySection suitability;
  final List<GovernmentScheme> governmentSchemes;
  final SowingPlanSection sowingPlan;
  final FertilizationSection fertilization;
  final IrrigationScheduleSection irrigation;
  final DiseaseProbabilitySection disease;
  final HarvestSection harvest;
  final ResidueSection residue;
  final StorageSection storage;
  final List<ValueAddedProduct> valueAddedProducts;
  final DirectSellingSection directSelling;
  final List<AlliedBusiness> alliedBusinessIdeas;
  final FertilizerCostSection fertilizerCost;
  final DateTime lastUpdated;
  
  AgentPlanModel({
    required this.cropId,
    required this.suitability,
    required this.governmentSchemes,
    required this.sowingPlan,
    required this.fertilization,
    required this.irrigation,
    required this.disease,
    required this.harvest,
    required this.residue,
    required this.storage,
    required this.valueAddedProducts,
    required this.directSelling,
    required this.alliedBusinessIdeas,
    required this.fertilizerCost,
    required this.lastUpdated,
  });
  
  factory AgentPlanModel.fromJson(Map<String, dynamic> json) {
    return AgentPlanModel(
      cropId: json['cropId'] ?? '',
      suitability: SuitabilitySection.fromJson(json['suitability'] ?? {}),
      governmentSchemes: (json['governmentSchemes'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => GovernmentScheme.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      sowingPlan: SowingPlanSection.fromJson(json['sowingPlan'] ?? {}),
      fertilization: FertilizationSection.fromJson(json['fertilization'] ?? {}),
      irrigation: IrrigationScheduleSection.fromJson(json['irrigation'] ?? {}),
      disease: DiseaseProbabilitySection.fromJson(json['disease'] ?? {}),
      harvest: HarvestSection.fromJson(json['harvest'] ?? {}),
      residue: ResidueSection.fromJson(json['residue'] ?? {}),
      storage: StorageSection.fromJson(json['storage'] ?? {}),
      valueAddedProducts: (json['valueAddedProducts'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => ValueAddedProduct.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      directSelling: DirectSellingSection.fromJson(json['directSelling'] ?? {}),
      alliedBusinessIdeas: (json['alliedBusinessIdeas'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => AlliedBusiness.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      fertilizerCost: FertilizerCostSection.fromJson(json['fertilizerCost'] ?? {}),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : DateTime.now(),
    );
  }

  // Adapter for new Rule-Based Backend Response
  factory AgentPlanModel.fromBackendResponse(Map<String, dynamic> data) {
    final cropPlanning = data['crop_planning'] is Map ? data['crop_planning'] as Map<String, dynamic> : <String, dynamic>{};
    final fertilization = data['fertilization'] is Map ? data['fertilization'] as Map<String, dynamic> : <String, dynamic>{};
    final irrigation = data['irrigation'] is Map ? data['irrigation'] as Map<String, dynamic> : <String, dynamic>{};
    final disease = data['disease_analysis'] is Map ? data['disease_analysis'] as Map<String, dynamic> : <String, dynamic>{};
    final harvest = data['harvest_prediction'] is Map ? data['harvest_prediction'] as Map<String, dynamic> : <String, dynamic>{};
    final price = data['price_analysis'] is Map ? data['price_analysis'] as Map<String, dynamic> : <String, dynamic>{};
    final summary = data['overall_summary']?.toString() ?? '';

    // EXTRACT SUITABILITY from crop_planning
    final recommendedCrops = (cropPlanning['recommended_crops'] is List) ? (cropPlanning['recommended_crops'] as List) : [];
    String score = 'N/A';
    List<String> recommendations = [];
    if (recommendedCrops.isNotEmpty) {
      final firstCrop = recommendedCrops[0];
      if (firstCrop is Map) {
         score = "${firstCrop['suitability_score']}%";
         recommendations.add(firstCrop['reasoning']?.toString() ?? '');
      }
    }
    if (summary.isNotEmpty) {
      recommendations.insert(0, summary);
    }
    
    // Safety check for seasons map
    final seasonalCalendar = cropPlanning['seasonal_calendar'] is Map ? cropPlanning['seasonal_calendar'] as Map<String, dynamic> : <String, dynamic>{};

    return AgentPlanModel(
      cropId: data['crop']?.toString() ?? '',
      suitability: SuitabilitySection(
        isSuitable: true, 
        suitabilityScore: score,
        soilValidation: "Consider soil testing for better accuracy", 
        recommendations: recommendations,
      ),
      governmentSchemes: [], 
      sowingPlan: SowingPlanSection(
        bestSowingWindow: seasonalCalendar['sowing_window']?.toString() ?? 'Check local advisory',
        weatherConsiderations: "Check forecast before sowing",
        tips: ["Use certified seeds"],
      ),
      fertilization: _mapFertilization(fertilization),
      irrigation: _mapIrrigation(irrigation),
      disease: _mapDisease(disease),
      harvest: _mapHarvest(harvest),
      residue: ResidueSection(utilizationMethods: ["Composting"], environmentalImpact: "Low"),
      storage: _mapStorage(price),
      valueAddedProducts: [], 
      directSelling: DirectSellingSection(platforms: [], tips: ["Sell directly at farm gate"]),
      alliedBusinessIdeas: [],
      fertilizerCost: FertilizerCostSection(comparison: [], recommendations: "Use generic fertilizers"),
      lastUpdated: DateTime.now(),
    );
  }

  static FertilizationSection _mapFertilization(Map<String, dynamic> fertData) {
    List<FertilizerApplication> schedule = [];
    final rawSchedule = fertData['fertilization_schedule'] as List?;
    if (rawSchedule != null) {
      for (var stage in rawSchedule) {
        // Handle list of fertilizers in stage
        final ferts = stage['fertilizers'] as List?;
        String fertStr = "Mixed";
        String qtyStr = "";
        if (ferts != null && ferts.isNotEmpty) {
          fertStr = ferts.map((f) => f['name']).join(' + ');
          qtyStr = ferts.map((f) => "${f['quantity_per_acre']} ${f['unit']}").join(' + ');
        }
        
        schedule.add(FertilizerApplication(
          stage: stage['stage'] ?? '',
          fertilizer: fertStr,
          quantity: qtyStr,
          method: "Broadcasting", // Default
        ));
      }
    }
    return FertilizationSection(schedule: schedule, lowCostAlternatives: []);
  }

  static IrrigationScheduleSection _mapIrrigation(Map<String, dynamic> irrData) {
    List<IrrigationStage> schedule = [];
    final rawSchedule = irrData['daily_schedule'] as List?; // Wait, irrigation agent returns map or list? 
    // Checking format: It returns 'irrigation_schedule': {'stage': {'frequency_days': X, 'water_mm': Y}}
    // Need to handle Map or List. Knowledge base returns Map.
    
    final schedMap = irrData['irrigation_schedule'];
    if (schedMap is Map) {
      schedMap.forEach((stage, details) {
        schedule.add(IrrigationStage(
          stage: stage,
          frequency: "Every ${details['frequency_days']} days",
          amount: "${details['water_mm']} mm",
        ));
      });
    }

    return IrrigationScheduleSection(
      schedule: schedule,
      waterRequirement: "Based on soil and weather",
    );
  }

  static DiseaseProbabilitySection _mapDisease(Map<String, dynamic> diseaseData) {
    // If specific analysis exists (from symptoms)
    // If generic info, layout common diseases
    // For now, map generic common diseases if available
    return DiseaseProbabilitySection(timeline: [], preventiveMeasures: ["Monitor regularly"]);
  }

  static HarvestSection _mapHarvest(Map<String, dynamic> harvestData) {
    return HarvestSection(
      expectedHarvestDate: harvestData['predicted_harvest_date'] ?? '',
      yieldPrediction: harvestData['estimated_yield'] != null ? "${harvestData['estimated_yield']['quantity']} ${harvestData['estimated_yield']['unit']}" : '',
      harvestIndicators: ["Check maturity indices"],
    );
  }

  static StorageSection _mapStorage(Map<String, dynamic> priceData) {
    return StorageSection(
      storageMethod: "Dry Storage",
      storageDuration: "N/A",
      pricePrediction: priceData['forecast']?['trend'] ?? "Stable",
      bestSellingTime: priceData['recommendation']?['action'] ?? "Monitor",
    );
  }
}

// Section 1: Crop Suitability & Soil Validation
class SuitabilitySection {
  final bool isSuitable;
  final String suitabilityScore;
  final String soilValidation;
  final List<String> recommendations;
  
  SuitabilitySection({
    required this.isSuitable,
    required this.suitabilityScore,
    required this.soilValidation,
    required this.recommendations,
  });
  
  factory SuitabilitySection.fromJson(Map<String, dynamic> json) {
    return SuitabilitySection(
      isSuitable: json['isSuitable'] ?? false,
      suitabilityScore: json['suitabilityScore'] ?? 'N/A',
      soilValidation: json['soilValidation'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

// Section 2: Government Schemes
class GovernmentScheme {
  final String name;
  final String description;
  final String eligibility;
  final String? applicationLink;
  
  GovernmentScheme({
    required this.name,
    required this.description,
    required this.eligibility,
    this.applicationLink,
  });
  
  factory GovernmentScheme.fromJson(Map<String, dynamic> json) {
    return GovernmentScheme(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      eligibility: json['eligibility'] ?? '',
      applicationLink: json['applicationLink'],
    );
  }
}

// Section 3: Sowing Time & Weather Planning
class SowingPlanSection {
  final String bestSowingWindow;
  final String weatherConsiderations;
  final List<String> tips;
  
  SowingPlanSection({
    required this.bestSowingWindow,
    required this.weatherConsiderations,
    required this.tips,
  });
  
  factory SowingPlanSection.fromJson(Map<String, dynamic> json) {
    return SowingPlanSection(
      bestSowingWindow: json['bestSowingWindow'] ?? '',
      weatherConsiderations: json['weatherConsiderations'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
    );
  }
}

// Section 4: Fertilization Plan
class FertilizationSection {
  final List<FertilizerApplication> schedule;
  final List<LowCostAlternative> lowCostAlternatives;
  
  FertilizationSection({
    required this.schedule,
    required this.lowCostAlternatives,
  });
  
  factory FertilizationSection.fromJson(Map<String, dynamic> json) {
    return FertilizationSection(
      schedule: (json['schedule'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => FertilizerApplication.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      lowCostAlternatives: (json['lowCostAlternatives'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => LowCostAlternative.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class FertilizerApplication {
  final String stage;
  final String fertilizer;
  final String quantity;
  final String method;
  
  FertilizerApplication({
    required this.stage,
    required this.fertilizer,
    required this.quantity,
    required this.method,
  });
  
  factory FertilizerApplication.fromJson(Map<String, dynamic> json) {
    return FertilizerApplication(
      stage: json['stage'] ?? '',
      fertilizer: json['fertilizer'] ?? '',
      quantity: json['quantity'] ?? '',
      method: json['method'] ?? '',
    );
  }
}

class LowCostAlternative {
  final String name;
  final String description;
  final String howToMake;
  
  LowCostAlternative({
    required this.name,
    required this.description,
    required this.howToMake,
  });
  
  factory LowCostAlternative.fromJson(Map<String, dynamic> json) {
    return LowCostAlternative(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      howToMake: json['howToMake'] ?? '',
    );
  }
}

// Section 5: Irrigation Schedule
class IrrigationScheduleSection {
  final List<IrrigationStage> schedule;
  final String waterRequirement;
  
  IrrigationScheduleSection({
    required this.schedule,
    required this.waterRequirement,
  });
  
  factory IrrigationScheduleSection.fromJson(Map<String, dynamic> json) {
    return IrrigationScheduleSection(
      schedule: (json['schedule'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => IrrigationStage.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      waterRequirement: json['waterRequirement'] ?? '',
    );
  }
}

class IrrigationStage {
  final String stage;
  final String frequency;
  final String amount;
  
  IrrigationStage({
    required this.stage,
    required this.frequency,
    required this.amount,
  });
  
  factory IrrigationStage.fromJson(Map<String, dynamic> json) {
    return IrrigationStage(
      stage: json['stage'] ?? '',
      frequency: json['frequency'] ?? '',
      amount: json['amount'] ?? '',
    );
  }
}

// Section 6: Disease Probability
class DiseaseProbabilitySection {
  final List<DiseaseTimeline> timeline;
  final List<String> preventiveMeasures;
  
  DiseaseProbabilitySection({
    required this.timeline,
    required this.preventiveMeasures,
  });
  
  factory DiseaseProbabilitySection.fromJson(Map<String, dynamic> json) {
    return DiseaseProbabilitySection(
      timeline: (json['timeline'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => DiseaseTimeline.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      preventiveMeasures: List<String>.from(json['preventiveMeasures'] ?? []),
    );
  }
}

class DiseaseTimeline {
  final String stage;
  final String diseaseName;
  final String probability;
  final String symptoms;
  
  DiseaseTimeline({
    required this.stage,
    required this.diseaseName,
    required this.probability,
    required this.symptoms,
  });
  
  factory DiseaseTimeline.fromJson(Map<String, dynamic> json) {
    return DiseaseTimeline(
      stage: json['stage'] ?? '',
      diseaseName: json['diseaseName'] ?? '',
      probability: json['probability'] ?? '',
      symptoms: json['symptoms'] ?? '',
    );
  }
}

// Section 8: Harvest Timing & Yield
class HarvestSection {
  final String expectedHarvestDate;
  final String yieldPrediction;
  final List<String> harvestIndicators;
  
  HarvestSection({
    required this.expectedHarvestDate,
    required this.yieldPrediction,
    required this.harvestIndicators,
  });
  
  factory HarvestSection.fromJson(Map<String, dynamic> json) {
    return HarvestSection(
      expectedHarvestDate: json['expectedHarvestDate'] ?? '',
      yieldPrediction: json['yieldPrediction'] ?? '',
      harvestIndicators: List<String>.from(json['harvestIndicators'] ?? []),
    );
  }
}

// Section 9: Crop Residue
class ResidueSection {
  final List<String> utilizationMethods;
  final String environmentalImpact;
  
  ResidueSection({
    required this.utilizationMethods,
    required this.environmentalImpact,
  });
  
  factory ResidueSection.fromJson(Map<String, dynamic> json) {
    return ResidueSection(
      utilizationMethods: List<String>.from(json['utilizationMethods'] ?? []),
      environmentalImpact: json['environmentalImpact'] ?? '',
    );
  }
}

// Section 10: Storage & Price
class StorageSection {
  final String storageMethod;
  final String storageDuration;
  final String pricePrediction;
  final String bestSellingTime;
  
  StorageSection({
    required this.storageMethod,
    required this.storageDuration,
    required this.pricePrediction,
    required this.bestSellingTime,
  });
  
  factory StorageSection.fromJson(Map<String, dynamic> json) {
    return StorageSection(
      storageMethod: json['storageMethod'] ?? '',
      storageDuration: json['storageDuration'] ?? '',
      pricePrediction: json['pricePrediction'] ?? '',
      bestSellingTime: json['bestSellingTime'] ?? '',
    );
  }
}

// Section 11: Value-Added Products
class ValueAddedProduct {
  final String name;
  final String description;
  final String marketPotential;
  
  ValueAddedProduct({
    required this.name,
    required this.description,
    required this.marketPotential,
  });
  
  factory ValueAddedProduct.fromJson(Map<String, dynamic> json) {
    return ValueAddedProduct(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      marketPotential: json['marketPotential'] ?? '',
    );
  }
}

// Section 12: Direct Selling
class DirectSellingSection {
  final List<Platform> platforms;
  final List<String> tips;
  
  DirectSellingSection({
    required this.platforms,
    required this.tips,
  });
  
  factory DirectSellingSection.fromJson(Map<String, dynamic> json) {
    return DirectSellingSection(
      platforms: (json['platforms'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => Platform.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      tips: List<String>.from(json['tips'] ?? []),
    );
  }
}

class Platform {
  final String name;
  final String description;
  final String? contactInfo;
  
  Platform({
    required this.name,
    required this.description,
    this.contactInfo,
  });
  
  factory Platform.fromJson(Map<String, dynamic> json) {
    return Platform(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      contactInfo: json['contactInfo'],
    );
  }
}

// Section 13: Allied Business
class AlliedBusiness {
  final String name;
  final String description;
  final String investment;
  
  AlliedBusiness({
    required this.name,
    required this.description,
    required this.investment,
  });
  
  factory AlliedBusiness.fromJson(Map<String, dynamic> json) {
    return AlliedBusiness(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      investment: json['investment'] ?? '',
    );
  }
}

// Section 14: Fertilizer Cost Comparison
class FertilizerCostSection {
  final List<FertilizerCost> comparison;
  final String recommendations;
  
  FertilizerCostSection({
    required this.comparison,
    required this.recommendations,
  });
  
  factory FertilizerCostSection.fromJson(Map<String, dynamic> json) {
    return FertilizerCostSection(
      comparison: (json['comparison'] as List?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => FertilizerCost.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      recommendations: json['recommendations'] ?? '',
    );
  }
}

class FertilizerCost {
  final String brand;
  final String type;
  final double price;
  final String unit;
  
  FertilizerCost({
    required this.brand,
    required this.type,required this.price,
    required this.unit,
  });
  
  factory FertilizerCost.fromJson(Map<String, dynamic> json) {
    return FertilizerCost(
      brand: json['brand'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'kg',
    );
  }
}
