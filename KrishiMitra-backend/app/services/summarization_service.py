"""
Summarization Service - Uses Gemini to summarize rule-based agent outputs
This is the ONLY place where Gemini is used in the refactored system
"""

from app.services.gemini_service import gemini_service
from typing import Dict, List
import json

class SummarizationService:
    """Service to summarize rule-based agent outputs using Gemini"""
    
    @staticmethod
    def summarize_crop_planning(agent_output: dict, user_context: dict = None) -> str:
        """Summarize crop planning recommendations"""
        prompt = f'''You are Krishidnya, a friendly AI assistant for Indian farmers.

The rule-based crop planning system has analyzed the farmer's soil and location data.
Summarize the following recommendations in a natural, conversational tone suitable for farmers.

**Agent Analysis Results:**
{json.dumps(agent_output, indent=2)}

**User Context:**
{json.dumps(user_context or {}, indent=2)}

**Instructions:**
1. Keep it simple and friendly - write like you're talking to a farmer in person
2. Highlight the top 2-3 crop recommendations
3. Mention why these crops are suitable
4. Include expected profits and duration
5. Keep it under 150 words
6. Use Indian Rupee symbol (₹) for money

Return ONLY the conversational summary text, no JSON.'''
        
        return gemini_service.generate_text_response(prompt, temperature=0.7)
    
    @staticmethod
    def summarize_fertilization(agent_output: dict, crop_name: str) -> str:
        """Summarize fertilization plan"""
        prompt = f'''You are Krishidnya, helping an Indian farmer with fertilization planning.

The rule-based fertilization system has created a detailed NPK plan for {crop_name}.
Summarize this plan in a friendly, easy-to-understand way.

**Fertilization Plan:**
{json.dumps(agent_output, indent=2)}

**Instructions:**
1. Explain the fertilization schedule simply
2. Mention total cost and potential savings
3. Give 2-3 key application tips
4. Keep it conversational and under 150 words
5. Use Indian Rupee symbol (₹)

Return ONLY the summary text, no JSON.'''
        
        return gemini_service.generate_text_response(prompt, temperature=0.7)
    
    @staticmethod
    def summarize_irrigation(agent_output: dict, crop_name: str) -> str:
        """Summarize irrigation schedule"""
        prompt = f'''You are Krishidnya, advising an Indian farmer on irrigation for {crop_name}.

The rule-based irrigation system has analyzed weather data and created a schedule.

**Irrigation Analysis:**
{json.dumps(agent_output, indent=2)}

**Instructions:**
1. Tell them when to irrigate next and why
2. Mention any weather-based adjustments
3. Include water-saving tips
4. Keep it friendly and under 120 words

Return ONLY the summary text, no JSON.'''
        
        return gemini_service.generate_text_response(prompt, temperature=0.7)
    
    @staticmethod
    def summarize_disease_detection(agent_output: dict, crop_name: str) -> str:
        """Summarize disease diagnosis and treatment"""
        prompt = f'''You are Krishidnya, helping an Indian farmer diagnose and treat crop disease.

The rule-based disease detection system has analyzed the symptoms for {crop_name}.

**Disease Analysis:**
{json.dumps(agent_output, indent=2)}

**Instructions:**
1. Explain the disease and severity clearly
2. Give immediate action steps
3. Mention both chemical and organic treatment options
4. Be reassuring but honest
5. Keep it under 150 words

Return ONLY the summary text, no JSON.'''
        
        return gemini_service.generate_text_response(prompt, temperature=0.7)
    
    @staticmethod
    def summarize_harvest_prediction(agent_output: dict, crop_name: str) -> str:
        """Summarize harvest predictions"""
        prompt = f'''You are Krishidnya, helping an Indian farmer plan their harvest for {crop_name}.

The rule-based harvest prediction system has calculated harvest timing and yield.

**Harvest Predictions:**
{json.dumps(agent_output, indent=2)}

**Instructions:**
1. Tell them when to harvest and expected yield
2. Mention quality grade
3. Give 2-3 pre-harvest action steps
4. Keep it encouraging and under 120 words

Return ONLY the summary text, no JSON.'''
        
        return gemini_service.generate_text_response(prompt, temperature=0.7)
    
    @staticmethod
    def summarize_price_analysis(agent_output: dict, crop_name: str) -> str:
        """Summarize market price analysis"""
        prompt = f'''You are Krishidnya, helping an Indian farmer get the best price for {crop_name}.

The rule-based price analysis system has analyzed multiple markets and transport costs.

**Market Analysis:**
{json.dumps(agent_output, indent=2)}

**Instructions:**
1. Recommend the best market to sell at
2. Mention the expected price after transport
3. Give selling strategy (immediate vs hold)
4. Keep it actionable and under 120 words

Return ONLY the summary text, no JSON.'''
        
        return gemini_service.generate_text_response(prompt, temperature=0.7)
    
    @staticmethod
    def summarize_comprehensive_analysis(all_agent_outputs: dict, crop_name: str, user_context: dict = None) -> str:
        """Create a comprehensive summary from multiple agents"""
        prompt = f'''You are Krishidnya, an AI agricultural advisor for Indian farmers.

Multiple rule-based agricultural agents have analyzed everything about growing {crop_name}.
Create a comprehensive yet easy-to-understand summary for the farmer.

**All Agent Outputs:**
{json.dumps(all_agent_outputs, indent=2)}

**Farmer Context:**
{json.dumps(user_context or {}, indent=2)}

**Instructions:**
1. Create a clear, structured summary covering all aspects:
   - Crop suitability and expected profit
   - Fertilization and irrigation needs
   - Disease prevention
   - Harvest timing
   - Best selling strategy
2. Make it actionable - what should the farmer do?
3. Keep it conversational and encouraging
4. Under 300 words total
5. Use Indian Rupee symbol (₹)

Return ONLY the comprehensive summary, no JSON.'''
        
        return gemini_service.generate_text_response(prompt, temperature=0.7)


# Singleton instance
summarization_service = SummarizationService()
