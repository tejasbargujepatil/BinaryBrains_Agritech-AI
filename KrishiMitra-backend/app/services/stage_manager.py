from datetime import datetime, date
from app.knowledge.crop_knowledge_base import get_crop_data

class StageManager:
    """
    Manages crop growth stage calculations based on sowing date and knowledge base.
    """
    
    @staticmethod
    def calculate_current_stage(crop_name: str, sowing_date: date) -> dict:
        """
        Calculate generic growth stage based on Days After Sowing (DAS)
        """
        if not sowing_date:
            return {"stage": "Unknown", "das": 0}
            
        today = date.today()
        das = (today - sowing_date).days
        
        if das < 0:
             return {"stage": "Planned", "das": das}

        crop_data = get_crop_data(crop_name)
        if not crop_data:
            return {"stage": "Unknown", "das": das}
            
        # Default Logic if no specific stage data structure exists in KB yet
        # We can infer from fertilization/irrigation schedules usually found in KB
        # But let's define a standard mapping if missing
        
        # Use simple mapping if not in KB
        # Typically:
        # 0-15: Germination
        # 15-45: Vegetative
        # 45-75: Flowering/Reproductive
        # 75-Harvest: Maturity
        
        # Or look at duration
        duration_days = crop_data.get("duration_months", 4) * 30
        
        stage = "Vegetative" # Default
        
        # Dynamic check based on % of lifecycle
        progress = das / duration_days
        
        if progress < 0.15:
            stage = "Germination/Seedling"
        elif progress < 0.45:
            stage = "Vegetative Growth"
        elif progress < 0.75:
             stage = "Flowering/Reproductive"
        elif progress < 1.0:
            stage = "Maturity/Fruiting"
        else:
            stage = "Harvest Ready"
            
        return {
            "stage": stage,
            "das": das,
            "progress_percent": int(progress * 100),
            "days_remaining": max(0, duration_days - das)
        }

stage_manager = StageManager()
