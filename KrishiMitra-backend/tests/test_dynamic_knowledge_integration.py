
import unittest
import os
import json
import logging
from app.services.dynamic_knowledge_service import dynamic_knowledge_service
from app.config import Config

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TestDynamicKnowledgeIntegration(unittest.TestCase):
    
    def setUp(self):
        # Check for API Keys
        self.gemini_key = os.getenv('GEMINI_API_KEY')
        if not self.gemini_key:
            logger.warning("SKIPPING TEST: GEMINI_API_KEY not found in environment.")
            self.skipTest("GEMINI_API_KEY not found")
            
        # Ensure we are testing with a crop that likely doesn't exist in static DB
        self.test_crop = "Dragon Fruit" 
        
    def test_fetch_and_store_live(self):
        """
        Integration test for DynamicKnowledgeService.
        1. Searches Google for 'Dragon Fruit'
        2. Scrapes content
        3. Uses Gemini to parse
        4. Stores in JSON
        """
        logger.info(f"Starting live integration test for crop: {self.test_crop}")
        
        # 1. Fetch Data
        result = dynamic_knowledge_service.fetch_and_store(self.test_crop)
        
        # 2. Validation
        if result is None:
            self.fail("dynamic_knowledge_service.fetch_and_store returned None. Search or Parsing failed.")
            
        logger.info("Successfully fetched data.")
        
        # Check structure
        required_keys = ['soil_requirements', 'fertilization_schedule', 'irrigation_schedule']
        for key in required_keys:
            self.assertIn(key, result, f"Result missing key: {key}")
            
        # Check content
        self.assertIn('Dragon Fruit', result.get('market_calendar', {}).get('notes', '') + str(result)) 
        # (loose check, just ensuring we got something relevant)
        
        # 3. Check Persistence
        storage_file = dynamic_knowledge_service.storage_file
        self.assertTrue(os.path.exists(storage_file), "Storage file was not created")
        
        with open(storage_file, 'r') as f:
            stored_data = json.load(f)
            
        self.assertIn(self.test_crop.lower(), stored_data, "Crop was not persisted to storage file")
        logger.info(f"Verified persistence in {storage_file}")
        
        # Print sample for user verification
        print("\n=== SAMPLE FETCHED DATA ===")
        print(json.dumps(result, indent=2)[:500] + "...\n")

if __name__ == '__main__':
    unittest.main()
