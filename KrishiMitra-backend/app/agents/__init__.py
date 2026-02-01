# Make agents easily importable
from app.agents.base_agent import BaseAgent
from app.agents.crop_planning_agent import CropPlanningAgent
from app.agents.fertilization_agent import FertilizationAgent
from app.agents.irrigation_agent import IrrigationAgent
from app.agents.disease_agent import DiseaseDetectionAgent, HarvestPredictionAgent, PricePredictionAgent
from app.agents.price_analysis_agent import PriceAnalysisAgent

# Agent instances
crop_planning_agent = CropPlanningAgent()
fertilization_agent = FertilizationAgent()
irrigation_agent = IrrigationAgent()
disease_detection_agent = DiseaseDetectionAgent()
harvest_prediction_agent = HarvestPredictionAgent()
price_prediction_agent = PricePredictionAgent()
price_analysis_agent = PriceAnalysisAgent()

__all__ = [
    'BaseAgent',
    'crop_planning_agent',
    'fertilization_agent',
    'irrigation_agent',
    'disease_detection_agent',
    'harvest_prediction_agent',
    'price_prediction_agent',
    'price_analysis_agent'
]
