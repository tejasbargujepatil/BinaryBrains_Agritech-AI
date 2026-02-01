import '../models/weather_model.dart';
import '../models/soil_model.dart';
import '../models/crop_model.dart';
import '../models/agent_plan_model.dart';
import '../config/app_config.dart';

/// Mock data service for demo mode - simplified version
class MockDataService {
  // Mock Weather Data
  static WeatherModel getMockWeather() {
    return WeatherModel(
      temperature: 28.5,
      condition: 'Partly Cloudy',
      humidity: 65.0,
      windSpeed: 12.0,
      rainProbability: 30.0,
      location: 'Pune, MH (Demo)', // Added
      timestamp: DateTime.now(),
    );
  }

  // Mock Soil Data
  static SoilModel getMockSoil() {
    return SoilModel(
      soilType: 'Black Soil (Regur)',
      ph: 7.2,
      nitrogen: 285.0, // Double is fine, Model accepts dynamic
      phosphorus: 45.0,
      potassium: 320.0,
      moisture: 35.0,
      organicCarbon: '0.75%', // Added
      timestamp: DateTime.now(),
    );
  }

  // Mock Crops List
  static List<CropModel> getMockCrops() {
    return [
      CropModel(
        id: 'crop_001',
        userId: 'demo_user_001',
        cropName: 'Cotton',
        sowingDate: DateTime.now().subtract(const Duration(days: 45)),
        landArea: 2.5,
        irrigationType: 'Drip',
        cropVariety: 'Bt Cotton',
        currentStage: 'Vegetative Growth',
        healthStatus: 'GOOD',
        lastUpdate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      CropModel(
        id: 'crop_002',
        userId: 'demo_user_001',
        cropName: 'Wheat',
        sowingDate: DateTime.now().subtract(const Duration(days: 60)),
        landArea: 3.0,
        irrigationType: 'Flood',
        cropVariety: 'HD-2967',
        currentStage: 'Tillering',
        healthStatus: 'EXCELLENT',
        lastUpdate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      CropModel(
        id: 'crop_003',
        userId: 'demo_user_001',
        cropName: 'Sugarcane',
        sowingDate: DateTime.now().subtract(const Duration(days: 90)),
        landArea: 1.5,
        irrigationType: 'Furrow',
        cropVariety: 'Co-86032',
        currentStage: 'Grand Growth',
        healthStatus: 'FAIR',
        lastUpdate: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  // Mock Agent Plan for a crop
  static AgentPlanModel getMockAgentPlan(String cropId) {
    return AgentPlanModel(
      cropId: cropId,
      lastUpdated: DateTime.now(),
      suitability: SuitabilitySection(
        isSuitable: true,
        suitabilityScore: '85%',
        soilValidation: 'Black soil is highly suitable for cotton cultivation',
        recommendations: [
          'Current soil pH (7.2) is ideal',
          'Nitrogen levels are adequate',
          'Add phosphorus-rich fertilizer',
        ],
      ),
      governmentSchemes: [
        GovernmentScheme(
          name: 'PM-KISAN',
          description: 'Income support of ₹6000/year',
          eligibility: 'All landholding farmer families',
          applicationLink: 'https://pmkisan.gov.in',
        ),
        GovernmentScheme(
          name: 'Soil Health Card Scheme',
          description: 'Free soil testing',
          eligibility: 'All farmers',
          applicationLink: 'https://soilhealth.dac.gov.in',
        ),
      ],
      sowingPlan: SowingPlanSection(
        bestSowingWindow: 'June 15 - July 15',
        weatherConsiderations: 'Sow when monsoon is established',
        tips: [
          'Use certified seeds',
          'Treat seeds with fungicide',
          'Maintain row spacing of 60cm',
        ],
      ),
      fertilization: FertilizationSection(
        schedule: [
          FertilizerApplication(
            stage: 'Basal (At Sowing)',
            fertilizer: 'DAP',
            quantity: '50 kg/acre',
            method: 'Broadcast',
          ),
          FertilizerApplication(
            stage: 'First Top Dressing (30 DAS)',
            fertilizer: 'Urea',
            quantity: '25 kg/acre',
            method: 'Side dressing',
          ),
          FertilizerApplication(
            stage: 'Second Top Dressing (60 DAS)',
            fertilizer: 'Urea + Potash',
            quantity: '25+20 kg/acre',
            method: 'Side dressing',
          ),
        ],
        lowCostAlternatives: [
          LowCostAlternative(
            name: 'Vermicompost',
            description: '1 ton/acre as basal',
            howToMake: 'Use crop residue and cow dung',
          ),
          LowCostAlternative(
            name: 'Neem Cake',
            description: '100 kg/acre',
            howToMake: 'Available at local markets',
          ),
        ],
      ),
      irrigation: IrrigationScheduleSection(
        schedule: [
          IrrigationStage(
            stage: 'Initial (0-30 days)',
            frequency: 'Every 7-10 days',
            amount: '2-3 inches',
          ),
          IrrigationStage(
            stage: 'Vegetative (30-60 days)',
            frequency: 'Every 5-7 days',
            amount: '3-4 inches',
          ),
          IrrigationStage(
            stage: 'Flowering (60-120 days)',
            frequency: 'Every 4-5 days',
            amount: '4-5 inches',
          ),
        ],
        waterRequirement: '24-28 inches for full crop cycle',
      ),
      disease: DiseaseProbabilitySection(
        timeline: [
          DiseaseTimeline(
            stage: 'Vegetative (30-45 DAS)',
            diseaseName: 'Bacterial Blight',
            probability: 'Medium (40%)',
            symptoms: 'Water-soaked lesions on leaves',
          ),
          DiseaseTimeline(
            stage: 'Boll Formation (75-120 DAS)',
            diseaseName: 'Pink Bollworm',
            probability: 'High (65%)',
            symptoms: 'Rosette flowers, boll damage',
          ),
        ],
        preventiveMeasures: [
          'Use disease-free seeds',
          'Install pheromone traps',
          'Spray neem oil weekly',
        ],
      ),
      harvest: HarvestSection(
        expectedHarvestDate: DateTime.now().add(const Duration(days: 120)).toString().split(' ')[0],
        yieldPrediction: '12-15 quintals per acre',
        harvestIndicators: [
          'Bolls fully opened (90%)',
          'Fibre turns white and fluffy',
          'Boll walls turn brown',
        ],
      ),
      residue: ResidueSection(
        utilizationMethods: [
          'Cattle feed: Cotton stalks as fodder',
          'Biogas: Shred and use in biogas plant',
          'Composting: Decompose with culture',
        ],
        environmentalImpact: 'Avoid burning - causes air pollution',
      ),
      storage: StorageSection(
        storageMethod: 'Covered warehouse with ventilation',
        storageDuration: '6-9 months',
        pricePrediction: '₹6,800 - ₹7,200 per quintal',
        bestSellingTime: 'March-April (peak prices)',
      ),
      valueAddedProducts: [
        ValueAddedProduct(
          name: 'Cotton Seed Oil',
          description: 'Extract oil from seeds',
          marketPotential: 'High demand, 30-40% profit',
        ),
        ValueAddedProduct(
          name: 'Organic Cotton',
          description: 'Certified organic',
          marketPotential: '20-30% price premium',
        ),
      ],
      directSelling: DirectSellingSection(
        platforms: [
          Platform(
            name: 'eNAM',
            description: 'Government online trading platform',
            contactInfo: 'enam.gov.in',
          ),
          Platform(
            name: 'Cotton Corporation of India',
            description: 'MSP procurement',
            contactInfo: 'Visit nearest CCI center',
          ),
        ],
        tips: [
          'Grade your cotton properly',
          'Keep moisture below 12%',
          'Get fair price estimates',
        ],
      ),
      alliedBusinessIdeas: [
        AlliedBusiness(
          name: 'Vermicompost Unit',
          description: 'Produce organic manure',
          investment: '₹25,000 - ₹50,000',
        ),
        AlliedBusiness(
          name: 'Drip Installation Service',
          description: 'Install drip systems for farmers',
          investment: '₹1,00,000 - ₹2,00,000',
        ),
        AlliedBusiness(
          name: 'Dairy Farming',
          description: 'Use cotton stalks as feed',
          investment: '₹2,00,000 - ₹5,00,000',
        ),
      ],
      fertilizerCost: FertilizerCostSection(
        comparison: [
          FertilizerCost(
            brand: 'IFFCO Urea',
            type: 'Urea',
            price: 242.0,
            unit: 'per 50kg bag',
          ),
          FertilizerCost(
            brand: 'Coromandel DAP',
            type: 'DAP',
            price: 1350.0,
            unit: 'per 50kg bag',
          ),
          FertilizerCost(
            brand: 'IFFCO MOP',
            type: 'Potash',
            price: 950.0,
            unit: 'per 50kg bag',
          ),
        ],
        recommendations: 'Use soil test reports. Mix organic with chemical fertilizers for cost savings.',
      ),
    );
  }
}
