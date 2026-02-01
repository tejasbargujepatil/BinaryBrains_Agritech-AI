from app.agents.base_agent import BaseAgent
from app.services.weather_service import weather_service
from app.knowledge.crop_knowledge_base import get_crop_data
from datetime import datetime, timedelta

class IrrigationAgent(BaseAgent):
    """Rule-based Agent for creating and auto-adjusting irrigation schedules"""
    
    def __init__(self):
        super().__init__('irrigation_agent')
    
    def execute(self, crop_name: str, growth_stage: str, soil_moisture: float,
                irrigation_type: str, location: dict) -> dict:
        """
        Create intelligent irrigation schedule using knowledge base and weather data
        
        Args:
            crop_name: Name of crop
            growth_stage: Current growth stage
            soil_moisture: Current moisture level (%)
            irrigation_type: drip/sprinkler/flood
            location: {latitude, longitude}
        
        Returns:
            Irrigation schedule with weather-based adjustments
        """
        # Get weather forecast
        if location.get('latitude', 0) == 0 and location.get('longitude', 0) == 0:
            # Fallback for invalid location
            weather = {
                'rain_expected_24h': False,
                'total_rainfall_mm': 0,
                'recommendation': 'Location not set - assuming standard conditions'
            }
        else:
            weather = weather_service.analyze_for_irrigation(
                location['latitude'],
                location['longitude']
            )
        
        # Get crop data
        crop_data = get_crop_data(crop_name.lower())
        
        if not crop_data:
            return {
                "error": f"Crop '{crop_name}' not found in knowledge base",
                "supported_crops": ["sugarcane", "cotton", "rice", "jowar", "wheat", "tur", "soybean", "groundnut", "sunflower", "gram"]
            }
        
        # Get base irrigation schedule
        irrigation_schedule = crop_data.get("irrigation_schedule", {})
        
        # Find matching growth stage
        stage_key = self._match_growth_stage(growth_stage, list(irrigation_schedule.keys()))
        base_schedule = irrigation_schedule.get(stage_key, {
            "frequency_days": 10,
            "water_mm": 50
        })
        
        # Get base irrigation parameters
        base_frequency = base_schedule["frequency_days"]
        base_water_mm = base_schedule["water_mm"]
        
        # Apply adjustment rules
        adjusted_water = base_water_mm
        adjustments = []
        
        # Rule 1: Soil moisture adjustment
        if soil_moisture > 70:
            adjusted_water *= 0.5
            adjustments.append(f"Reduced water by 50% due to high soil moisture ({soil_moisture}%)")
        elif soil_moisture > 50:
            adjusted_water *= 0.75
            adjustments.append(f"Reduced water by 25% due to adequate soil moisture ({soil_moisture}%)")
        elif soil_moisture < 30:
            adjusted_water *= 1.2
            adjustments.append(f"Increased water by 20% due to low soil moisture ({soil_moisture}%)")
        
        # Rule 2: Weather adjustment
        rain_expected = weather.get('rain_expected_24h', False)
        rainfall_mm = weather.get('total_rainfall_mm', 0)
        
        should_irrigate = True
        if rain_expected and rainfall_mm > 10:
            should_irrigate = False
            adjustments.append(f"Skipping irrigation - {rainfall_mm}mm rain predicted")
        elif rainfall_mm > 5:
            adjusted_water *= 0.7
            adjustments.append(f"Reduced water by 30% due to expected {rainfall_mm}mm rain")
        
        # Rule 3: Irrigation type efficiency
        efficiency_factors = {
            "drip": 0.9,
            "sprinkler": 0.75,
            "flood": 0.6
        }
        efficiency = efficiency_factors.get(irrigation_type.lower(), 0.75)
        duration_minutes = int((adjusted_water / efficiency) * 2)  # Approx duration
        
        # Calculate next irrigation date
        next_date = datetime.now() + timedelta(days=base_frequency if should_irrigate else base_frequency + 2)
        
        # Build 7-day schedule
        schedule_7days = self._build_7day_schedule(
            base_frequency, adjusted_water, weather, soil_moisture
        )
        
        # Water saving tips
        water_saving_tips = [
            f"Use {irrigation_type} irrigation - {int(efficiency*100)}% efficient",
            "Irrigate early morning (5-8 AM) to reduce evaporation by 30%",
            "Mulch around plants to retain moisture",
            "Check soil moisture before each irrigation"
        ]
        
        # Critical stages upcoming
        critical_stages = self._get_critical_stages(crop_data, growth_stage)
        
        return {
            "next_irrigation": {
                "date": next_date.strftime("%Y-%m-%d"),
                "time": "06:00 AM",
                "water_amount_mm": int(adjusted_water),
                "duration_minutes": duration_minutes,
                "reason": f"Soil moisture at {soil_moisture}%, weather considered, crop stage: {growth_stage}"
            },
            "should_irrigate_now": should_irrigate,
            "adjustments_made": adjustments if adjustments else ["No adjustments needed"],
            "next_7_days_schedule": schedule_7days,
            "water_saving_tips": water_saving_tips,
            "critical_stages_upcoming": critical_stages,
            "weather_data": {
                "rain_expected": weather['rain_expected_24h'],
                "rainfall_mm": weather['total_rainfall_mm'],
                "recommendation": weather['recommendation']
            },
            "analysis_method": "rule_based_knowledge_base"
        }
    
    def _match_growth_stage(self, input_stage: str, available_stages: list) -> str:
        """Match input growth stage to available stages"""
        input_lower = input_stage.lower()
        
        # Direct match
        for stage in available_stages:
            if input_lower in stage.lower() or stage.lower() in input_lower:
                return stage
        
        # Stage mapping
        stage_map = {
            "germination": ["germination", "sowing", "seed"],
            "vegetative": ["vegetative", "tillering", "growth"],
            "flowering": ["flowering", "flower", "reproductive", "panicle", "jointing"],
            "maturity": ["maturity", "ripening", "grain_filling", "dough"]
        }
        
        for key, variants in stage_map.items():
            if any(v in input_lower for v in variants):
                for stage in available_stages:
                    if key in stage.lower():
                        return stage
        
        # Default to first stage
        return available_stages[0] if available_stages else "vegetative"
    
    def _build_7day_schedule(self, frequency: int, water_mm: int, weather: dict, soil_moisture: float) -> list:
        """Build 7-day irrigation schedule"""
        schedule = []
        current_date = datetime.now()
        
        for day in range(7):
            date = current_date + timedelta(days=day)
            irrigate = (day % frequency == 0) and soil_moisture < 70
            
            notes = "Normal irrigation" if irrigate else "No irrigation needed"
            if day < 2 and weather.get('rain_expected_24h'):
                irrigate = False
                notes = f"Rain predicted ({weather.get('total_rainfall_mm', 0)}mm)"
            
            schedule.append({
                "date": date.strftime("%Y-%m-%d"),
                "irrigate": irrigate,
                "water_mm": int(water_mm) if irrigate else 0,
                "notes": notes
            })
        
        return schedule
    
    def _get_critical_stages(self, crop_data: dict, current_stage: str) -> list:
        """Get upcoming critical growth stages"""
        all_stages = list(crop_data.get("irrigation_schedule", {}).keys())
        
        critical_patterns = ["flowering", "flower", "reproductive", "grain", "pod"]
        critical_stages = []
        
        for stage in all_stages:
            if any(pattern in stage.lower() for pattern in critical_patterns):
                if stage.lower() != current_stage.lower():
                    critical_stages.append({
                        "stage": stage.title(),
                        "starts_in_days": 15,  # Approximate
                        "water_requirement": "Critical - maintain optimal moisture"
                    })
        
        return critical_stages[:2]  # Return top 2 upcoming critical stages

    def check_daily_status(self, crop_name: str, growth_stage: str, sowing_date: datetime, 
                          location: dict, last_irrigated_date: datetime = None) -> dict:
        """
        Proactive daily check for irrigation needs.
        Returns alert dict if action is needed.
        """
        # 1. Get Weather
        # Get weather forecast
        if location.get('latitude', 0) == 0 and location.get('longitude', 0) == 0:
             # Can't give specific weather advice without location
            return None
        
        weather = weather_service.analyze_for_irrigation(
                location['latitude'],
                location['longitude']
        )
        
        rain_predicted = weather.get('rain_expected_24h', False)
        rainfall_mm = weather.get('total_rainfall_mm', 0)
        
        # 2. Check Schedule
        # Simple rule: If rain predicted > 5mm, ALERT to SKIP
        if rain_predicted and rainfall_mm > 5:
            return {
                "type": "irrigation_skip",
                "severity": "medium",
                "message": f"Rain predicted ({rainfall_mm}mm). Skip irrigation for {crop_name}.",
                "icon": "cloud_off"
            }
            
        # 3. Check if irrigation due (Generic logic)
        # If no rain, and it's been a while (mock logic calling execute would be expensive/complex here without state)
        # For now, simplistic active check:
        if weather.get('temperature_max', 30) > 38:
             return {
                "type": "irrigation_advisory",
                "severity": "high",
                "message": f"Heatwave alert ({weather.get('temperature_max')}°C). Ensure {crop_name} is well-watered.",
                "icon": "water_drop"
            }
            
        return None
