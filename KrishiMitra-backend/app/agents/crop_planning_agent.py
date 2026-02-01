from app.agents.base_agent import BaseAgent
from app.knowledge.crop_knowledge_base import match_crop_to_soil, get_crop_data
from app.services.weather_service import weather_service
from app.services.soil_service import soil_service
from datetime import datetime, timedelta

class CropPlanningAgent(BaseAgent):
    """
    Agent responsible for recommending crops based on soil, season, and market data.
    Now integrates real-time Weather and Soil APIs for enhanced accuracy.
    """
    
    def __init__(self):
        super().__init__('crop_planning_agent')
    
    def execute(self, soil_data: dict, location: dict, user_preferences: dict = None) -> dict:
        """
        Analyze soil and location to recommend best crops using rule-based logic & real-time API data
        
        Args:
            soil_data: {nitrogen, phosphorus, potassium, ph, soil_type} (Optional)
            location: {latitude, longitude, location_name}
            user_preferences: {budget, risk_tolerance, farm_size}
        
        Returns:
            dict with recommended crops, suitability scores, and task schedules
        """
        # 1. Enrich Soil Data if missing (using Soil Service)
        if not self._is_valid_soil_data(soil_data) and location.get('latitude') and location.get('longitude'):
            fetched_soil = soil_service.get_soil_data(location['latitude'], location['longitude'])
            # Merge fetched data, prioritizing user input if partial data exists
            if not fetched_soil.get('error'):
                soil_data = {**fetched_soil, **soil_data}
                # Ensure defaults if still missing
                if 'nitrogen' not in soil_data: soil_data['nitrogen'] = 40
                if 'phosphorus' not in soil_data: soil_data['phosphorus'] = 30
                if 'potassium' not in soil_data: soil_data['potassium'] = 20
                if 'ph' not in soil_data: soil_data['ph'] = 7.0
            
        # 2. Get Weather Context (using Weather Service)
        weather_context = {}
        if location.get('latitude') and location.get('longitude'):
            try:
                # Use analyze_for_irrigation to get a quick precip check, or just get current weather
                # Let's get current weather for risk assessment
                weather_context = weather_service.get_current_weather(location['latitude'], location['longitude'])
            except Exception as e:
                pass

        current_month = datetime.now().month
        
        # 3. Get crop recommendations using knowledge base
        # If soil data is still empty (no location, no input), we can't recommend much, but match_crop_to_soil handles it gracefully?
        # Let's assume soil_data is populated now or we use defaults.
        all_matches = match_crop_to_soil(soil_data, current_month)
        
        # 4. Refine & Rank Recommendations
        top_5 = all_matches[:5]
        
        recommended_crops = []
        for crop in top_5:
            crop_name = crop["crop_name"]
            crop_data = get_crop_data(crop_name)
            if not crop_data: continue

            # Calculate expected profit
            market_calendar = crop_data.get("market_calendar", {})
            avg_price = market_calendar.get("avg_price_per_quintal", 3000)
            yield_data = crop_data.get("expected_yield", {})
            avg_yield = (yield_data.get("min", 0) + yield_data.get("max", 0)) / 2
            expected_profit = avg_price * avg_yield
            
            # Refine Risk Level with Weather Data
            risk_level = self._calculate_risk_level(crop_data, weather_context)
            
            # Generate Task Schedule
            task_schedule = self._generate_task_schedule(crop_data, datetime.now())

            recommended_crops.append({
                "crop_name": crop_name.title(),
                "marathi_name": crop["marathi_name"],
                "variety": crop_data.get("varieties", ["Standard"])[0],
                "suitability_score": crop["suitability_score"],
                "expected_profit_per_acre": int(expected_profit),
                "risk_level": risk_level,
                "reasoning": ". ".join(crop["reasons"]),
                "growing_season": crop_data.get("seasons", ["Year-round"])[0],
                "task_schedule": task_schedule
            })
            
        return {
            "recommended_crops": recommended_crops,
            "soil_data_used": soil_data,
            "weather_context": "Weather data integrated" if weather_context else "Weather data unavailable",
            "analysis_method": "rule_based_plus_realtime_api"
        }

    def _is_valid_soil_data(self, soil_data: dict) -> bool:
        """Check if soil data has required NPK values"""
        if not soil_data: return False
        return all(k in soil_data for k in ['nitrogen', 'phosphorus', 'potassium'])

    def _calculate_risk_level(self, crop_data: dict, weather_context: dict) -> str:
        """Calculate risk based on crop duration and current weather"""
        base_risk = "Low"
        duration = crop_data.get("duration_months", 4)
        
        # Increase risk if long duration crop
        if duration > 5:
            base_risk = "Medium"
            
        # Check current weather if available
        # OpenWeather 'rain' dict usually has '1h' or '3h' key
        rain_data = weather_context.get('rain', {})
        rain_1h = rain_data.get('1h', 0) if isinstance(rain_data, dict) else 0
        
        if rain_1h > 5:
             base_risk = "High (Heavy Rain Alert)"
             
        return base_risk

    def _generate_task_schedule(self, crop_data: dict, start_date: datetime) -> list:
        """Generate a simple task schedule based on crop stages"""
        schedule = []
        duration_days = crop_data.get("duration_months", 4) * 30
        
        # 1. Sowing
        schedule.append({
            "task": "Sowing/Planting",
            "date": start_date.strftime("%Y-%m-%d"),
            "notes": "Ensure soil moisture is adequate."
        })
        
        # 2. Fertilization (Basal & Top Dressing)
        fert_schedule = crop_data.get("fertilization_schedule", [])
        for stage in fert_schedule:
            # Map simple stages to days (Heuristic mapping)
            stage_name = stage.get('stage', '').lower()
            if 'basal' in stage_name or 'sowing' in stage_name:
                day_offset = 0
            elif 'vegetative' in stage_name:
                day_offset = 30
            elif 'flowering' in stage_name:
                day_offset = 60
            elif 'fruiting' in stage_name:
                day_offset = 90
            else:
                day_offset = stage.get("timing_days", 15)
                
            task_date = start_date + timedelta(days=day_offset)
            # Avoid duplicate dates if possible, or just append
            schedule.append({
                "task": f"Fertilization: {stage.get('stage', 'Application')}",
                "date": task_date.strftime("%Y-%m-%d"),
                "details": f"Apply {', '.join([f['name'] for f in stage.get('fertilizers', [])])}"
            })
            
        # 3. Harvest
        harvest_date = start_date + timedelta(days=duration_days)
        schedule.append({
            "task": "Harvesting",
            "date": harvest_date.strftime("%Y-%m-%d"),
            "notes": f"Check for maturity signs: {', '.join(crop_data.get('harvest_indicators', {}).get('physical_signs', []))}"
        })
        
        return sorted(schedule, key=lambda x: x['date'])
