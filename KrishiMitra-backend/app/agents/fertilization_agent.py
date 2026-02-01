from app.agents.base_agent import BaseAgent
from app.knowledge.crop_knowledge_base import get_crop_data, get_fertilizer_price, FERTILIZER_PRICES

class FertilizationAgent(BaseAgent):
    """Rule-based Agent for creating fertilization plans"""
    
    def __init__(self):
        super().__init__('fertilization_agent')
    
    def execute(self, crop_name: str, current_soil_npk: dict, growth_stage: str, 
                land_area: float = 1.0) -> dict:
        """
        Create optimal fertilization plan using knowledge base
        
        Args:
            crop_name: Name of the crop
            current_soil_npk: {nitrogen, phosphorus, potassium}
            growth_stage: Current growth stage
            land_area: Area in acres
        
        Returns:
            Complete fertilization plan with NPK requirements, products, and schedule
        """
        crop_data = get_crop_data(crop_name.lower())
        
        if not crop_data:
            return {
                "error": f"Crop '{crop_name}' not found in knowledge base",
                "supported_crops": ["sugarcane", "cotton", "rice", "jowar", "wheat", "tur", "soybean", "groundnut", "sunflower", "gram"]
            }
        
        # Get NPK requirements
        npk_req = crop_data["soil_requirements"]["npk_requirements"]
        
        # Get fertilization schedule
        fert_schedule = crop_data.get("fertilization_schedule", [])
        
        # Build fertilizer plan
        fertilizer_plan = []
        total_cost = 0
        
        for stage_plan in fert_schedule:
            stage_fertilizers = []
            stage_cost = 0
            
            for fert in stage_plan["fertilizers"]:
                quantity_total = fert["quantity_per_acre"] * land_area
                price_per_50kg = get_fertilizer_price(fert["name"])
                
                # Calculate cost
                bags_needed = quantity_total / 50
                cost = bags_needed * price_per_50kg
                stage_cost += cost
                
                stage_fertilizers.append({
                    "product": fert["name"],
                    "npk": fert["npk"],
                    "quantity_per_acre": f"{fert['quantity_per_acre']}{fert['unit']}",
                    "total_quantity": f"{quantity_total:.1f}{fert['unit']}",
                    "price_per_50kg": price_per_50kg,
                    "total_cost": int(cost)
                })
            
            fertilizer_plan.append({
                "stage": stage_plan["stage"],
                "timing": f"{stage_plan['timing_days']} days after planting",
                "fertilizers": stage_fertilizers,
                "stage_cost": int(stage_cost)
            })
            total_cost += stage_cost
        
        # Find cheaper alternatives
        cheaper_alternatives = self._find_cheaper_alternatives()
        
        # Calculate potential savings
        potential_savings = len(fertilizer_plan) * 100 * land_area  # Approx savings
        
        # Application tips
        application_tips = [
            "Apply fertilizers in morning or evening to reduce losses",
            "Water immediately after application for better absorption",
            "Keep fertilizers away from plant stem to avoid burning",
            "Use government-subsidized brands like IFFCO, NFL, RCF for savings"
        ]
        
        return {
            "npk_requirement": {
                "nitrogen": f"{npk_req['nitrogen']['min']}-{npk_req['nitrogen']['max']} kg/acre",
                "phosphorus": f"{npk_req['phosphorus']['min']}-{npk_req['phosphorus']['max']} kg/acre",
                "potassium": f"{npk_req['potassium']['min']}-{npk_req['potassium']['max']} kg/acre"
            },
            "fertilizer_plan": fertilizer_plan,
            "total_cost_per_acre": int(total_cost / land_area),
            "total_cost_for_area": int(total_cost),
            "land_area_acres": land_area,
            "cheaper_alternatives": cheaper_alternatives,
            "potential_savings": int(potential_savings),
            "application_tips": application_tips,
            "analysis_method": "rule_based_knowledge_base"
        }
    
    def find_cheaper_alternatives(self, current_fertilizer: dict) -> dict:
        """Find cheaper alternatives to current fertilizer"""
        npk_target = current_fertilizer.get('npk', '0-0-0')
        current_price = current_fertilizer.get('price', 0)
        
        alternatives = []
        for name, data in FERTILIZER_PRICES.items():
            if data['npk'] == npk_target and data['price'] < current_price:
                savings = current_price - data['price']
                alternatives.append({
                    "brand": name.split()[0],  # Get brand name
                    "product_name": name,
                    "npk_ratio": data['npk'],
                    "price_per_50kg": data['price'],
                    "savings": savings,
                    "availability": "Government cooperative - widely available",
                    "reasoning": f"Save ₹{savings} per bag with government cooperative pricing"
                })
        
        alternatives.sort(key=lambda x: x['price_per_50kg'])
        
        total_savings = sum(alt['savings'] for alt in alternatives[:3])
        
        return {
            "cheaper_alternatives": alternatives[:5],
            "total_savings": total_savings,
            "recommendation": alternatives[0]['product_name'] if alternatives else "Current option is best"
        }
    
    def _find_cheaper_alternatives(self) -> list:
        """Get general fertilizer savings tips"""
        return [
            "Buy from government cooperatives (IFFCO, NFL, RCF) for subsidized prices",
            "Purchase during off-season for 5-10% discount",
            "Use vermicompost to reduce chemical fertilizer need by 20-30%",
            "Join FPO (Farmer Producer Organization) for bulk discounts"
        ]
