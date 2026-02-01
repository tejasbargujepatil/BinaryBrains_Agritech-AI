"""
Agent Orchestrator - Manages execution of multiple rule-based agents
"""

from app.agents.crop_planning_agent import CropPlanningAgent
from app.agents.fertilization_agent import FertilizationAgent
from app.agents.irrigation_agent import IrrigationAgent
from app.agents.disease_agent import DiseaseDetectionAgent, HarvestPredictionAgent, PricePredictionAgent
from app.agents.price_analysis_agent import PriceAnalysisAgent
from app.services.summarization_service import summarization_service
from typing import Dict, List, Optional
import logging

logger = logging.getLogger(__name__)

class AgentOrchestrator:
    """Orchestrates execution of multiple rule-based agents and summarizes results"""
    
    def __init__(self):
        # Initialize all agents
        self.crop_planning_agent = CropPlanningAgent()
        self.fertilization_agent = FertilizationAgent()
        self.irrigation_agent = IrrigationAgent()
        self.disease_agent = DiseaseDetectionAgent()
        self.harvest_agent = HarvestPredictionAgent()
        self.price_prediction_agent = PricePredictionAgent()
        self.price_analysis_agent = PriceAnalysisAgent()
    
    def analyze_crop_planning(self, soil_data: dict, location: dict, 
                             user_preferences: dict = None, summarize: bool = True) -> dict:
        """Execute crop planning analysis with optional summary"""
        try:
            # Run rule-based agent
            agent_result = self.crop_planning_agent.execute(
                soil_data=soil_data,
                location=location,
                user_preferences=user_preferences or {}
            )
            
            # Optionally summarize with Gemini
            if summarize and agent_result.get("recommended_crops"):
                summary = summarization_service.summarize_crop_planning(
                    agent_result,
                    user_context={"location": location.get("location_name", ""), "preferences": user_preferences or {}}
                )
                agent_result["ai_summary"] = summary
            
            return agent_result
            
        except Exception as e:
            logger.error(f"Crop planning analysis failed: {str(e)}")
            return {"error": str(e), "agent": "crop_planning"}
    
    def analyze_fertilization(self, crop_name: str, current_soil_npk: dict, 
                             growth_stage: str, land_area: float = 1.0, 
                             summarize: bool = True) -> dict:
        """Execute fertilization planning with optional summary"""
        try:
            agent_result = self.fertilization_agent.execute(
                crop_name=crop_name,
                current_soil_npk=current_soil_npk,
                growth_stage=growth_stage,
                land_area=land_area
            )
            
            if summarize and not agent_result.get("error"):
                summary = summarization_service.summarize_fertilization(agent_result, crop_name)
                agent_result["ai_summary"] = summary
            
            return agent_result
            
        except Exception as e:
            logger.error(f"Fertilization analysis failed: {str(e)}")
            return {"error": str(e), "agent": "fertilization"}
    
    def analyze_irrigation(self, crop_name: str, growth_stage: str, soil_moisture: float,
                          irrigation_type: str, location: dict, summarize: bool = True) -> dict:
        """Execute irrigation scheduling with optional summary"""
        try:
            agent_result = self.irrigation_agent.execute(
                crop_name=crop_name,
                growth_stage=growth_stage,
                soil_moisture=soil_moisture,
                irrigation_type=irrigation_type,
                location=location
            )
            
            if summarize and not agent_result.get("error"):
                summary = summarization_service.summarize_irrigation(agent_result, crop_name)
                agent_result["ai_summary"] = summary
            
            return agent_result
            
        except Exception as e:
            logger.error(f"Irrigation analysis failed: {str(e)}")
            return {"error": str(e), "agent": "irrigation"}
    
    def analyze_disease(self, crop_name: str, symptoms: str, 
                       image_analysis: dict = None, summarize: bool = True) -> dict:
        """Execute disease detection with optional summary"""
        try:
            agent_result = self.disease_agent.execute(
                crop_name=crop_name,
                symptoms=symptoms,
                image_analysis=image_analysis
            )
            
            if summarize and not agent_result.get("error"):
                summary = summarization_service.summarize_disease_detection(agent_result, crop_name)
                agent_result["ai_summary"] = summary
            
            return agent_result
            
        except Exception as e:
            logger.error(f"Disease detection failed: {str(e)}")
            return {"error": str(e), "agent": "disease_detection"}
    
    def analyze_harvest(self, crop_name: str, sowing_date: str, growth_data: dict,
                       weather_history: dict = None, summarize: bool = True) -> dict:
        """Execute harvest prediction with optional summary"""
        try:
            agent_result = self.harvest_agent.execute(
                crop_name=crop_name,
                sowing_date=sowing_date,
                growth_data=growth_data,
                weather_history=weather_history
            )
            
            if summarize and not agent_result.get("error"):
                summary = summarization_service.summarize_harvest_prediction(agent_result, crop_name)
                agent_result["ai_summary"] = summary
            
            return agent_result
            
        except Exception as e:
            logger.error(f"Harvest prediction failed: {str(e)}")
            return {"error": str(e), "agent": "harvest_prediction"}
    
    def analyze_price_trend(self, crop_name: str, harvest_date: str, 
                           current_price: float = None, summarize: bool = False) -> dict:
        """Execute price trend prediction (usually embedded in comprehensive analysis)"""
        try:
            agent_result = self.price_prediction_agent.execute(
                crop_name=crop_name,
                harvest_date=harvest_date,
                current_price=current_price
            )
            
            return agent_result
            
        except Exception as e:
            logger.error(f"Price prediction failed: {str(e)}")
            return {"error": str(e), "agent": "price_prediction"}
    
    def analyze_markets(self, crop_name: str, markets: list, user_location: dict,
                       summarize: bool = True) -> dict:
        """Execute market price analysis with optional summary"""
        try:
            agent_result = self.price_analysis_agent.execute(
                crop_name=crop_name,
                markets=markets,
                user_location=user_location
            )
            
            if summarize and not agent_result.get("error"):
                summary = summarization_service.summarize_price_analysis(agent_result, crop_name)
                agent_result["ai_summary"] = summary
            
            return agent_result
            
        except Exception as e:
            logger.error(f"Market analysis failed: {str(e)}")
            return {"error": str(e), "agent": "price_analysis"}
    
    def comprehensive_analysis(self, crop_name: str, analysis_data: dict, 
                              summarize: bool = True) -> dict:
        """
        Execute comprehensive multi-agent analysis for a crop
        
        Args:
            crop_name: Name of crop
            analysis_data: Dict containing all necessary data for all agents
            summarize: Whether to generate AI summary
        
        Returns:
            Combined results from all applicable agents with optional summary
        """
        results = {
            "crop_name": crop_name,
            "analysis_timestamp": __import__('datetime').datetime.now().isoformat(),
            "agents_executed": []
        }
        
        # Execute each agent if data is available
        if analysis_data.get("soil_data") and analysis_data.get("location"):
            results["crop_planning"] = self.analyze_crop_planning(
                soil_data=analysis_data["soil_data"],
                location=analysis_data["location"],
                user_preferences=analysis_data.get("user_preferences"),
                summarize=False  # Don't summarize individual agents
            )
            results["agents_executed"].append("crop_planning")
        
        if analysis_data.get("soil_npk") and analysis_data.get("growth_stage"):
            results["fertilization"] = self.analyze_fertilization(
                crop_name=crop_name,
                current_soil_npk=analysis_data["soil_npk"],
                growth_stage=analysis_data["growth_stage"],
                land_area=analysis_data.get("land_area", 1.0),
                summarize=False
            )
            results["agents_executed"].append("fertilization")
        
        if analysis_data.get("soil_moisture") and analysis_data.get("irrigation_type") and analysis_data.get("location"):
            results["irrigation"] = self.analyze_irrigation(
                crop_name=crop_name,
                growth_stage=analysis_data.get("growth_stage", "vegetative"),
                soil_moisture=analysis_data["soil_moisture"],
                irrigation_type=analysis_data["irrigation_type"],
                location=analysis_data["location"],
                summarize=False
            )
            results["agents_executed"].append("irrigation")
        
        if analysis_data.get("sowing_date") and analysis_data.get("growth_data"):
            results["harvest"] = self.analyze_harvest(
                crop_name=crop_name,
                sowing_date=analysis_data["sowing_date"],
                growth_data=analysis_data["growth_data"],
                weather_history=analysis_data.get("weather_history"),
                summarize=False
            )
            results["agents_executed"].append("harvest")
        
        if analysis_data.get("markets") and analysis_data.get("location"):
            results["market_analysis"] = self.analyze_markets(
                crop_name=crop_name,
                markets=analysis_data["markets"],
                user_location=analysis_data["location"],
                summarize=False
            )
            results["agents_executed"].append("market_analysis")
        
        # Generate comprehensive summary using Gemini
        if summarize and len(results["agents_executed"]) > 0:
            try:
                comprehensive_summary = summarization_service.summarize_comprehensive_analysis(
                    all_agent_outputs=results,
                    crop_name=crop_name,
                    user_context=analysis_data.get("user_context")
                )
                results["comprehensive_ai_summary"] = comprehensive_summary
            except Exception as e:
                logger.error(f"Comprehensive summarization failed: {str(e)}")
                results["summary_error"] = str(e)
        
        return results


# Singleton instance
orchestrator = AgentOrchestrator()
