class FertilizerRecommendation {
  final String brand;
  final String productName;
  final String npkRatio;
  final double estimatedPrice;
  final String priceRange;
  final String availability;
  final String reasoning;
  final List<String> alternatives;

  FertilizerRecommendation({
    required this.brand,
    required this.productName,
    required this.npkRatio,
    required this.estimatedPrice,
    required this.priceRange,
    required this.availability,
    required this.reasoning,
    required this.alternatives,
  });

  factory FertilizerRecommendation.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendation(
      brand: json['brand'] ?? '',
      productName: json['productName'] ?? '',
      npkRatio: json['npkRatio'] ?? '',
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
      priceRange: json['priceRange'] ?? '',
      availability: json['availability'] ?? 'Unknown',
      reasoning: json['reasoning'] ?? '',
      alternatives: (json['alternatives'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'productName': productName,
      'npkRatio': npkRatio,
      'estimatedPrice': estimatedPrice,
      'priceRange': priceRange,
      'availability': availability,
      'reasoning': reasoning,
      'alternatives': alternatives,
    };
  }
}

class FertilizerAnalysisResponse {
  final List<FertilizerRecommendation> recommendations;
  final String summary;

  FertilizerAnalysisResponse({
    required this.recommendations,
    required this.summary,
  });

  factory FertilizerAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final recommendations = (json['recommendations'] as List?)
        ?.map((e) => FertilizerRecommendation.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    
    return FertilizerAnalysisResponse(
      recommendations: recommendations,
      summary: json['summary'] ?? '',
    );
  }
}
