# Make models importable from app.models
from app.models.user import User
from app.models.crop import Crop
from app.models.fertilization import SoilData, FertilizationPlan, IrrigationSchedule
from app.models.disease import DiseaseDetection, HarvestPrediction, PricePrediction, AgentLog

__all__ = [
    'User',
    'Crop',
    'SoilData',
    'FertilizationPlan',
    'IrrigationSchedule',
    'DiseaseDetection',
    'HarvestPrediction',
    'PricePrediction',
    'AgentLog'
]
