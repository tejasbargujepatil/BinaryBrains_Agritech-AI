from app.agents.base_agent import BaseAgent
from app.knowledge.crop_knowledge_base import get_crop_data
from datetime import datetime, timedelta

class DiseaseDetectionAgent(BaseAgent):
    """Rule-based Agent for detecting crop diseases and recommending treatment"""
    
    def __init__(self):
        super().__init__('disease_detection_agent')
    
    def execute(self, crop_name: str, symptoms: str, image_analysis: dict = None) -> dict:
        """
        Detect disease and provide treatment plan using knowledge base
        
        Args:
            crop_name: Name of crop
            symptoms: Observed symptoms description
            image_analysis: Optional image analysis data
        
        Returns:
            Disease diagnosis and treatment plan
        """
        crop_data = get_crop_data(crop_name.lower())
        
        if not crop_data:
            return {
                "error": f"Crop '{crop_name}' not found in knowledge base",
                "supported_crops": ["sugarcane", "cotton", "rice", "jowar", "wheat", "tur", "soybean", "groundnut", "sunflower", "gram"]
            }
        
        # Get disease database for this crop
        diseases = crop_data.get("common_diseases", {})
        
        if not diseases:
            return {
                "disease_name": "Unknown",
                "message": "No disease database available for this crop",
                "recommendation": "Consult agricultural expert for diagnosis"
            }
        
        # Match symptoms to diseases
        symptoms_lower = symptoms.lower()
        disease_matches = []
        
        for disease_name, disease_info in diseases.items():
            symptom_list = disease_info.get("symptoms", [])
            
            # Count matching symptoms
            matches = 0
            for symptom in symptom_list:
                if any(word in symptoms_lower for word in symptom.lower().split()):
                    matches += 1
            
            if matches > 0:
                confidence = int((matches / len(symptom_list)) * 100)
                disease_matches.append({
                    "disease_key": disease_name,
                    "disease_info": disease_info,
                    "confidence": confidence,
                    "matches": matches
                })
        
        # Sort by confidence
        disease_matches.sort(key=lambda x: x["confidence"], reverse=True)
        
        if not disease_matches:
            return {
                "disease_name": "No Match Found",
                "confidence_score": 0,
                "message": f"Symptoms don't match known diseases for {crop_name}",
                "recommendation": "Please provide more detailed symptoms or consult expert",
                "common_diseases_for_crop": list(diseases.keys())
            }
        
        # Get top match
        top_match = disease_matches[0]
        disease_key = top_match["disease_key"]
        disease_info = top_match["disease_info"]
        confidence = top_match["confidence"]
        
        # Format disease name
        disease_name_formatted = disease_key.replace("_", " ").title()
        
        # Determine severity based on confidence and symptom count
        if confidence > 70:
            severity = "High"
        elif confidence > 40:
            severity = "Moderate"
        else:
            severity = "Low"
        
        # Get treatment plan
        chemical_treatment = disease_info.get("treatment_chemical", "Not specified")
        organic_treatment = disease_info.get("treatment_organic", "Not specified")
        prevention = disease_info.get("prevention", [])
        
        # Build response
        return {
            "disease_name": disease_name_formatted,
            "scientific_name": disease_key,
            "confidence_score": confidence,
            "severity": severity,
            "affected_parts": ["Leaves", "Stems"],  # Generic, can be enhanced
            "diagnosis": {
                "symptoms_match": disease_info["symptoms"],
                "spread_risk": "High" if severity == "High" else "Medium",
                "yield_impact": f"{confidence}% confidence - treat immediately" if severity == "High" else "Moderate impact if untreated"
            },
            "immediate_actions": [
                "Remove and destroy heavily infected plant parts",
                "Isolate infected area to prevent spread",
                "Improve ventilation and reduce humidity"
            ],
            "chemical_treatment": {
                "recommended_product": chemical_treatment.split("@")[0].strip(),
                "dosage": chemical_treatment.split("@")[1].strip() if "@" in chemical_treatment else "As per label",
                "application_frequency": "Every 7-10 days until control achieved",
                "safety_precautions": ["Wear protective gear", "Avoid spraying before rain", "Follow label instructions"]
            },
            "organic_alternatives": [
                {
                    "treatment": organic_treatment.split("@")[0].strip(),
                    "dosage": organic_treatment.split("@")[1].strip() if "@" in organic_treatment else "As recommended",
                    "effectiveness": "70-80%"
                }
            ],
            "preventive_measures": prevention,
            "monitoring_plan": [
                "Inspect plants daily for new symptoms",
                "Check fields early morning when symptoms are most visible",
                "Maintain field hygiene to prevent recurrence"
            ],
            "expected_recovery_time": "2-3 weeks with proper treatment",
            "alternative_diagnoses": [
                {"disease": match["disease_key"].replace("_", " ").title(), "confidence": match["confidence"]}
                for match in disease_matches[1:3]
            ] if len(disease_matches) > 1 else [],
            "analysis_method": "rule_based_knowledge_base"
        }


class HarvestPredictionAgent(BaseAgent):
    """Rule-based Agent for predicting harvest timing and yield"""
    
    def __init__(self):
        super().__init__('harvest_prediction_agent')
    
    def execute(self, crop_name: str, sowing_date: str, growth_data: dict, 
                weather_history: dict = None) -> dict:
        """
        Predict harvest date and yield using knowledge base rules
        
        Args:
            crop_name: Name of crop
            sowing_date: Date when crop was sown (YYYY-MM-DD)
            growth_data: Growth metrics and observations
            weather_history: Historical weather data
        
        Returns:
            Harvest predictions and recommendations
        """
        crop_data = get_crop_data(crop_name.lower())
        
        if not crop_data:
            return {
                "error": f"Crop '{crop_name}' not found in knowledge base",
                "supported_crops": ["sugarcane", "cotton", "rice", "jowar", "wheat", "tur", "soybean", "groundnut", "sunflower", "gram"]
            }
        
        # Parse sowing date
        try:
            sow_date = datetime.strptime(sowing_date, "%Y-%m-%d")
        except:
            sow_date = datetime.now() - timedelta(days=60)
        
        # Get harvest indicators
        harvest_info = crop_data.get("harvest_indicators", {})
        maturity_days = harvest_info.get("maturity_days", 120)
        
        # Calculate predicted harvest date
        predicted_harvest = sow_date + timedelta(days=maturity_days)
        days_remaining = (predicted_harvest - datetime.now()).days
        
        # Adjust for weather if provided
        weather_factor = 1.0
        if weather_history:
            rainfall_adequacy = weather_history.get("rainfall_adequacy", "Normal")
            if rainfall_adequacy == "Deficit":
                # Drought delays harvest
                predicted_harvest += timedelta(days=5)
                days_remaining += 5
                weather_factor = 0.9
            elif rainfall_adequacy == "Excess":
                # Too much rain may delay or reduce yield
                weather_factor = 0.85
        
        # Get expected yield
        yield_info = crop_data.get("expected_yield", {})
        min_yield = yield_info.get("min", 10)
        max_yield = yield_info.get("max", 15)
        avg_yield = (min_yield + max_yield) / 2
        
        # Adjust yield based on health status
        health_status = growth_data.get("health_status", "Good")
        pest_incidents = growth_data.get("pest_incidents", 0)
        disease_incidents = growth_data.get("disease_incidents", 0)
        
        yield_factor = 1.0
        if health_status == "Excellent":
            yield_factor = 1.1
        elif health_status == "Good":
            yield_factor = 1.0
        elif health_status == "Fair":
            yield_factor = 0.85
        else:  # Poor
            yield_factor = 0.7
        
        # Reduce yield for pests/diseases
        yield_factor -= (pest_incidents * 0.05)
        yield_factor -= (disease_incidents * 0.1)
        yield_factor = max(0.5, yield_factor)  # Minimum 50% yield
        
        # Calculate final yield prediction
        estimated_yield = avg_yield * yield_factor * weather_factor
        
        # Determine quality grade
        if yield_factor > 1.05:
            quality_grade = "A+"
        elif yield_factor > 0.95:
            quality_grade = "A"
        elif yield_factor > 0.8:
            quality_grade = "B"
        else:
            quality_grade = "C"
        
        # Get harvest indicators
        physical_signs = harvest_info.get("physical_signs", ["Crop mature", "Seeds hard"])
        
        # Build factors affecting yield
        factors_affecting = []
        if weather_history:
            rainfall_status = weather_history.get("rainfall_adequacy", "Normal")
            factors_affecting.append(f"Rainfall: {rainfall_status}")
        if pest_incidents > 0:
            factors_affecting.append(f"{pest_incidents} pest incident(s) recorded")
        if disease_incidents > 0:
            factors_affecting.append(f"{disease_incidents} disease incident(s) recorded")
        factors_affecting.append(f"Overall health: {health_status}")
        
        # Optimal harvest window (±3 days from predicted date)
        optimal_start = predicted_harvest - timedelta(days=3)
        optimal_end = predicted_harvest + timedelta(days=3)
        
        return {
            "predicted_harvest_date": predicted_harvest.strftime("%Y-%m-%d"),
            "days_remaining": max(0, days_remaining),
            "confidence_level": 85 if health_status == "Good" else 75,
            "yield_prediction": {
                "estimated_yield_per_acre": round(estimated_yield, 1),
                "unit": yield_info.get("unit", "quintals"),
                "quality_grade": quality_grade,
                "factors_affecting": factors_affecting
            },
            "harvest_indicators": physical_signs,
            "optimal_harvest_window": {
                "start_date": optimal_start.strftime("%Y-%m-%d"),
                "end_date": optimal_end.strftime("%Y-%m-%d"),
                "reason": "Maintain quality grade and timing for best market prices"
            },
            "pre_harvest_actions": [
                {
                    "action": "Stop irrigation",
                    "timing": "7-10 days before harvest",
                    "reason": "Allow crop to dry naturally for easier harvest"
                },
                {
                    "action": "Monitor for late-stage pests",
                    "timing": "Weekly until harvest",
                    "reason": "Prevent last-minute crop damage"
                },
                {
                    "action": "Arrange harvesting equipment",
                    "timing": "1 week before harvest",
                    "reason": "Ensure timely harvest within optimal window"
                }
            ],
            "post_harvest_plan": {
                "drying_method": "Sun drying for 2-3 days",
                "storage_conditions": "Cool, dry place with proper ventilation",
                "market_timing": "Sell within 2-3 weeks for best prices"
            },
            "risk_factors": [
                "Unseasonal rain during harvest can delay by 5-7 days",
                f"Pest/disease pressure may reduce yield by {int((1-yield_factor)*100)}%"
            ],
            "analysis_method": "rule_based_knowledge_base"
        }


class PricePredictionAgent(BaseAgent):
    """Rule-based Agent for predicting crop prices and suggesting selling strategy"""
    
    def __init__(self):
        super().__init__('price_prediction_agent')
    
    def execute(self, crop_name: str, harvest_date: str, current_price: float = None) -> dict:
        """
        Predict future prices and recommend selling strategy using market calendar rules
        
        Args:
            crop_name: Name of crop
            harvest_date: Expected harvest date (YYYY-MM-DD)
            current_price: Current market price (optional)
        
        Returns:
            Price predictions and selling strategy
        """
        crop_data = get_crop_data(crop_name.lower())
        
        if not crop_data:
            return {
                "error": f"Crop '{crop_name}' not found in knowledge base",
                "supported_crops": ["sugarcane", "cotton", "rice", "jowar", "wheat", "tur", "soybean", "groundnut", "sunflower", "gram"]
            }
        
        # Get market calendar
        market_calendar = crop_data.get("market_calendar", {})
        avg_price = market_calendar.get("avg_price_per_quintal", 
                                        market_calendar.get("avg_price_per_ton", 3000))
        peak_price = market_calendar.get("price_variation", {}).get("peak", avg_price * 1.1)
        off_price = market_calendar.get("price_variation", {}).get("off_season", avg_price * 0.9)
        peak_months = market_calendar.get("peak_demand_months", [])
        
        # Use current price if provided, otherwise use average
        if current_price is None:
            current_price = avg_price
        
        # Parse harvest date
        try:
            harvest_dt = datetime.strptime(harvest_date, "%Y-%m-%d")
        except:
            harvest_dt = datetime.now() + timedelta(days=30)
        
        # Determine if harvest is in peak season
        harvest_month = harvest_dt.month
        in_peak_season = harvest_month in peak_months
        
        # Price trend based on season
        if in_peak_season:
            trend = "stable_to_rising"
            trend_analysis = f"Harvest in peak demand season ({harvest_dt.strftime('%B')})"
        else:
            trend = "falling"
            trend_analysis = "Harvest outside peak demand period"
        
        # Generate price predictions
        # 1 week prediction
        one_week_date = harvest_dt + timedelta(days=7)
        one_week_month = one_week_date.month
        if one_week_month in peak_months:
            one_week_price = current_price * 1.03
        else:
            one_week_price = current_price * 0.98
        
        # 2 weeks prediction
        two_week_date = harvest_dt + timedelta(days=14)
        two_week_month = two_week_date.month
        if two_week_month in peak_months:
            two_week_price = current_price * 1.08
        else:
            two_week_price = current_price * 0.95
        
        # 1 month prediction
        one_month_date = harvest_dt + timedelta(days=30)
        one_month_month = one_month_date.month
        if one_month_month in peak_months:
            one_month_price = current_price * 1.12
        else:
            one_month_price = current_price * 0.92
        
        # Selling strategy
        if in_peak_season:
            recommendation = "Sell within 1-2 weeks"
            optimal_date = (harvest_dt + timedelta(days=7)).strftime("%Y-%m-%d")
            expected_price = int(one_week_price)
            reasoning = f"Peak demand season. Prices favorable now."
        else:
            # Check if peak season is approaching
            months_to_peak = min([abs(month - harvest_month) if abs(month - harvest_month) <= 6 
                                 else 12 - abs(month - harvest_month) 
                                 for month in peak_months])
            
            if months_to_peak <= 2:
                recommendation = "Hold for 2-4 weeks for peak season"
                optimal_date = one_month_date.strftime("%Y-%m-%d")
                expected_price = int(peak_price)
                reasoning = f"Peak season approaching in {months_to_peak} month(s). Hold for better prices."
            else:
                recommendation = "Sell immediately"
                optimal_date = harvest_dt.strftime("%Y-%m-%d")
                expected_price = int(current_price)
                reasoning = "Peak season distant. Avoid storage costs."
        
        potential_gain = expected_price - current_price
        
        return {
            "current_price_analysis": {
                "current_price_per_quintal": int(current_price),
                "market_status": "Peak season" if in_peak_season else "Off-season",
                "trend": trend
            },
            "price_predictions": {
                "1_week": {
                    "price": int(one_week_price),
                    "change_percent": round(((one_week_price - current_price) / current_price) * 100, 1),
                    "confidence": 80
                },
                "2_weeks": {
                    "price": int(two_week_price),
                    "change_percent": round(((two_week_price - current_price) / current_price) * 100, 1),
                    "confidence": 70
                },
                "1_month": {
                    "price": int(one_month_price),
                    "change_percent": round(((one_month_price - current_price) / current_price) * 100, 1),
                    "confidence": 60
                }
            },
            "selling_strategy": {
                "recommendation": recommendation,
                "optimal_selling_date": optimal_date,
                "expected_price": expected_price,
                "potential_gain": int(potential_gain),
                "reasoning": reasoning
            },
            "market_insights": [
                f"Peak demand months: {', '.join([datetime(2026, m, 1).strftime('%B') for m in peak_months])}",
                f"Average market price: ₹{int(avg_price)}/quintal",
                f"Peak season price: ₹{int(peak_price)}/quintal",
                "Store in proper conditions to avoid quality deterioration"
            ],
            "risk_factors": [
                {
                    "factor": "Market glut if many farmers harvest simultaneously",
                    "impact": "Prices may drop 10-15%",
                    "probability": "Medium"
                },
                {
                    "factor": "Storage costs and quality deterioration",
                    "impact": "₹50-100/quintal/month storage cost",
                    "probability": "High if holding beyond 1 month"
                }
            ],
            "alternate_strategies": [
                {
                    "strategy": "Sell 60% immediately, hold 40%",
                    "pros": "Hedge against price volatility",
                    "cons": "Storage costs for held portion"
                },
                {
                    "strategy": "Sell via e-NAM platform",
                    "pros": "Better price discovery, transparent bidding",
                    "cons": "Requires registration and digital literacy"
                }
            ],
            "direct_selling_platforms": [
                "e-NAM (National Agricultural Market)",
                "FPO/Cooperative societies",
                "Direct to food processors/mills"
            ],
            "analysis_method": "rule_based_knowledge_base"
        }
