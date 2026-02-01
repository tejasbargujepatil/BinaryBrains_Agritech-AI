class MarketPlace {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final String arrivalDate;
  final double modalPrice;
  final double minPrice;
  final double maxPrice;

  double? latitude;
  double? longitude;
  double? distanceKm;

  MarketPlace({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.arrivalDate,
    required this.modalPrice,
    required this.minPrice,
    required this.maxPrice,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  /// Factory from backend API response
  factory MarketPlace.fromJson(Map<String, dynamic> json) {
    return MarketPlace(
      state: json['state'] ?? json['State'] ?? '',
      district: json['district'] ?? json['District'] ?? '',
      market: json['market'] ?? json['Market'] ?? '',
      commodity: json['commodity'] ?? json['Commodity'] ?? '',
      variety: json['variety'] ?? json['Variety'] ?? '',
      arrivalDate: json['arrival_date'] ?? json['Arrival_Date'] ?? '',
      modalPrice: _parsePrice(json['modal_price'] ?? json['Modal_Price'] ?? json['Modal_x0020_Price']),
      minPrice: _parsePrice(json['min_price'] ?? json['Min_Price'] ?? json['Min_x0020_Price']),
      maxPrice: _parsePrice(json['max_price'] ?? json['Max_Price'] ?? json['Max_x0020_Price']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      distanceKm: json['distance_km']?.toDouble(),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'district': district,
      'market': market,
      'commodity': commodity,
      'variety': variety,
      'arrival_date': arrivalDate,
      'modal_price': modalPrice,
      'min_price': minPrice,
      'max_price': maxPrice,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
    };
  }
}

class PriceAnalysis {
  final Map<String, dynamic> bestMarket;
  final List<Map<String, dynamic>> top3Markets;
  final Map<String, dynamic> priceTrend;
  final Map<String, dynamic> sellingStrategy;
  final Map<String, dynamic>? transportAdvice;
  final List<Map<String, dynamic>>? riskFactors;
  final String? finalRecommendation;

  PriceAnalysis({
    required this.bestMarket,
    required this.top3Markets,
    required this.priceTrend,
    required this.sellingStrategy,
    this.transportAdvice,
    this.riskFactors,
    this.finalRecommendation,
  });

  factory PriceAnalysis.fromJson(Map<String, dynamic> json) {
    return PriceAnalysis(
      bestMarket: json['best_market'] ?? {},
      top3Markets: List<Map<String, dynamic>>.from(json['top_3_markets'] ?? []),
      priceTrend: json['price_trend'] ?? {},
      sellingStrategy: json['selling_strategy'] ?? {},
      transportAdvice: json['transport_advice'],
      riskFactors: json['risk_factors'] != null 
          ? List<Map<String, dynamic>>.from(json['risk_factors'])
          : null,
      finalRecommendation: json['final_recommendation'],
    );
  }
}
