from duckduckgo_search import DDGS
import requests
from bs4 import BeautifulSoup
from app.services.gemini_service import gemini_service
import json
import os
import logging
import time

logger = logging.getLogger(__name__)

class DynamicKnowledgeService:
    """Service to fetch, structure, and store agricultural data for new crops"""
    
    def __init__(self, storage_file='app/knowledge/dynamic_knowledge.json'):
        self.storage_file = storage_file
        self.dynamic_knowledge = self._load_knowledge()
        
    def _load_knowledge(self) -> dict:
        """Load persistent dynamic knowledge from JSON"""
        if os.path.exists(self.storage_file):
            try:
                with open(self.storage_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Failed to load dynamic knowledge: {e}")
                return {}
        return {}
    
    def _save_knowledge(self):
        """Save dynamic knowledge to JSON"""
        try:
            os.makedirs(os.path.dirname(self.storage_file), exist_ok=True)
            with open(self.storage_file, 'w') as f:
                json.dump(self.dynamic_knowledge, f, indent=2, ensure_ascii=False)
        except Exception as e:
            logger.error(f"Failed to save dynamic knowledge: {e}")

    def fetch_and_store(self, crop_name: str) -> dict:
        """
        Fetch data for a new crop from web, structure it, and store it.
        Returns the structured crop data.
        """
        crop_key = crop_name.lower().strip()
        
        # Check if already exists in dynamic storage
        if crop_key in self.dynamic_knowledge:
            return self.dynamic_knowledge[crop_key]
        
        logger.info(f"Fetching data for new crop: {crop_name}")
        
        # 1. Search Web (using DuckDuckGo as it's more robust to bots)
        search_queries = [
            f"{crop_name} crop farming guide India soil climate",
            f"{crop_name} fertilizer schedule per acre India",
            f"{crop_name} crop diseases and treatment India"
        ]
        
        raw_text_content = ""
        urls_visited = []
        
        try:
            for query in search_queries:
                logger.info(f"Searching for: {query}")
                # Search top results
                try:
                    # DDGS().text returns list of dicts {'href': ..., 'title': ..., 'body': ...}
                    # Use direct instantiation as it worked in debug script
                    results = list(DDGS().text(query, max_results=3))
                    logger.info(f"Search query executed, found {len(results)} results.")
                    time.sleep(2) # Avoid rate limits
                except Exception as e:
                    logger.warning(f"Search query '{query}' failed: {e}")
                    continue
                
                count = 0
                for result in results:
                    count += 1
                    url = result.get('href')
                    logger.info(f"Processing Result {count}: {url}")
                    
                    if not url or url in urls_visited:
                        logger.info("Skipping (duplicate or no URL).")
                        continue
                        
                    try:
                        # Basic scraping
                        # Use a timeout and robust headers
                        logger.info(f"Scraping: {url}...")
                        response = requests.get(url, timeout=10, headers={
                            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                        })
                        logger.info(f"Scrape Status: {response.status_code}")
                        
                        if response.status_code == 200:
                            soup = BeautifulSoup(response.text, 'html.parser')
                            # Extract useful text: headings and paragraphs
                            # Remove script and style elements
                            for script in soup(["script", "style", "nav", "footer", "header"]):
                                script.extract()
                                
                            text = soup.get_text(separator=' ', strip=True)
                            logger.info(f"Extracted {len(text)} chars from {url}")
                            
                            # Limit text length to avoid token limits later
                            raw_text_content += f"\n\nSource: {url}\n{text[:3000]}" 
                            urls_visited.append(url)
                        else:
                            logger.warning(f"Failed to scrape (Status {response.status_code}): {url}")
                    except Exception as e:
                        logger.warning(f"Failed to scrape {url}: {e}")
                    
                    if len(urls_visited) >= 5: # Limit total sources
                        break
                
                if len(urls_visited) >= 5:
                    break
            
            if not raw_text_content:
                logger.error(f"No content found for {crop_name}. Search might have failed.")
                return None
                
            # 2. Use Gemini to structure data using proper context
            structured_data = self._process_with_gemini(crop_name, raw_text_content)
            
            if structured_data:
                # 3. Store in dynamic knowledge
                self.dynamic_knowledge[crop_key] = structured_data
                self._save_knowledge()
                return structured_data
            
        except Exception as e:
            logger.error(f"Error in dynamic knowledge fetch for {crop_name}: {e}")
            return None
            
        return None

    def _process_with_gemini(self, crop_name: str, raw_text: str) -> dict:
        """Process raw text into standard knowledge base structure"""
        prompt = f"""You are an agricultural data scientist. 
        Extract structured data for the crop '{crop_name}' from the provided raw text.
        
        Structure the output EXACTLY like this JSON format:
        {{
            "marathi_name": "Marathi Name",
            "scientific_name": "Scientific Name",
            "varieties": ["Variety 1", "Variety 2"],
            "duration_months": 4, 
            "seasons": ["Kharif", "Rabi"],
            "soil_requirements": {{
                "ph": {{"min": 6.0, "max": 7.5}},
                "soil_type": ["Type 1", "Type 2"],
                "npk_requirements": {{
                    "nitrogen": {{"min": 50, "max": 60}},
                    "phosphorus": {{"min": 40, "max": 50}},
                    "potassium": {{"min": 30, "max": 40}}
                }}
            }},
            "fertilization_schedule": [
                {{
                    "stage": "Basal Application",
                    "timing_days": 0,
                    "fertilizers": [
                        {{
                            "name": "Urea",
                            "quantity_per_acre": 25,
                            "unit": "kg",
                            "npk": "46-0-0"
                        }}
                    ]
                }}
            ],
            "irrigation_schedule": {{
                "vegetative": {{
                    "frequency_days": 10,
                    "water_mm": 50
                }}
            }},
            "common_diseases": {{
                "disease_name": {{
                    "symptoms": ["symptom 1", "symptom 2"],
                    "treatment_chemical": "Chemical name",
                    "treatment_organic": "Organic method",
                    "prevention": ["prevention tip"]
                }}
            }},
            "harvest_indicators": {{
                "maturity_days": 120,
                "physical_signs": ["sign 1", "sign 2"]
            }},
            "expected_yield": {{
                "min": 10,
                "max": 15,
                "unit": "quintals/acre"
            }},
            "market_calendar": {{
                "peak_demand_months": [1, 2],
                "avg_price_per_quintal": 5000
            }}
        }}
        
        Raw Text Context:
        {raw_text[:15000]}
        
        Return ONLY valid JSON. Fill missing numeric values with reasonable estimates for India.
        """
        
        try:
            return gemini_service.generate_json_response(prompt, temperature=0.2)
        except Exception as e:
            logger.error(f"Gemini parsing failed: {e}")
            return None

# Singleton instance
dynamic_knowledge_service = DynamicKnowledgeService()
