import google.generativeai as genai
from app.config import Config
import json

class GeminiService:
    """Service for interacting with Google Gemini AI"""
    
    def __init__(self):
        self.api_key = Config.GEMINI_API_KEY
        if not self.api_key:
            raise ValueError("GEMINI_API_KEY not configured")
        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel('gemini-pro')
    
    def generate_response(self, prompt: str, temperature: float = 0.7) -> str:
        """Generate response from Gemini AI"""
        try:
            response = self.model.generate_content(
                prompt,
                generation_config=genai.types.GenerationConfig(
                    temperature=temperature,
                )
            )
            return response.text
        except Exception as e:
            raise Exception(f"Gemini AI error: {str(e)}")
    
    def generate_json_response(self, prompt: str, temperature: float = 0.7) -> dict:
        """Generate JSON response from Gemini AI"""
        response_text = self.generate_response(prompt, temperature)
        
        # Clean markdown code blocks if present
        cleaned = response_text.strip()
        if cleaned.startswith('```json'):
            cleaned = cleaned[7:]
        elif cleaned.startswith('```'):
            cleaned = cleaned[3:]
        if cleaned.endswith('```'):
            cleaned = cleaned[:-3]
        cleaned = cleaned.strip()
        
        try:
            return json.loads(cleaned)
        except json.JSONDecodeError as e:
            raise Exception(f"Failed to parse JSON response: {str(e)}\nResponse: {response_text}")
    
    def analyze_with_context(self, system_prompt: str, user_input: dict) -> dict:
        """Analyze with system context and user input"""
        full_prompt = f"{system_prompt}\n\nUser Input:\n{json.dumps(user_input, indent=2)}"
        return self.generate_json_response(full_prompt)


# Singleton instance
gemini_service = GeminiService()
