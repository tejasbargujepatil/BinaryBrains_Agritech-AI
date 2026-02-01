import requests
from app.config import Config
import time

class DataGovService:
    """Service for fetching crop market prices from data.gov.in AGMARKNET API"""
    
    def __init__(self):
        self.api_key = Config.DATA_GOV_API_KEY
        self.dataset_id = Config.DATASET_ID
        self.base_url = f"https://api.data.gov.in/resource/{self.dataset_id}"
        self.cache = {}  # Simple in-memory cache
        self.cache_time = 0
        self.cache_duration = 3600  # 1 hour
    
    def fetch_all_records(self, limit_per_page=1000, max_total=20000):
        """
        Fetch all records from data.gov.in API with pagination
       
        Returns:
            List of market records
        """
        # Check cache first
        if time.time() - self.cache_time < self.cache_duration and self.cache:
            return self.cache.get('records', [])
        
        all_records = []
        offset = 0
        
        try:
            while True:
                params = {
                    'api-key': self.api_key,
                    'format': 'json',
                    'limit': limit_per_page,
                    'offset': offset
                }
                
                response = requests.get(self.base_url, params=params, timeout=30)
                response.raise_for_status()
                
                data = response.json()
                records = data.get('records', [])
                
                if not records:
                    break
                
                all_records.extend(records)
                offset += len(records)
                
                if offset >= max_total or len(records) < limit_per_page:
                    break
            
            # Cache the results
            self.cache['records'] = all_records
            self.cache_time = time.time()
            
            return all_records
            
        except Exception as e:
            print(f"Data.gov.in API error: {e}")
            # Return cached data if available
            return self.cache.get('records', [])
    
    def filter_by_location(self, records, state=None, district=None):
        """Filter records by state and/or district"""
        filtered = records
        
        if state:
            state_lower = state.lower()
            filtered = [r for r in filtered if r.get('state', '').lower().find(state_lower) != -1]
        
        if district:
            district_lower = district.lower()
            filtered = [r for r in filtered if r.get('district', '').lower().find(district_lower) != -1]
        
        return filtered
    
    def filter_by_commodity(self, records, commodity):
        """Filter records by commodity name"""
        commodity_lower = commodity.lower()
        return [r for r in records if r.get('commodity', '').lower().find(commodity_lower) != -1]
    
    def get_nearby_markets(self, state, district, commodities=None):
        """
        Get nearby market prices
        
        Args:
            state: State name
            district: District name
            commodities: List of commodity names (optional)
        
        Returns:
            List of market records
        """
        records = self.fetch_all_records()
        filtered = self.filter_by_location(records, state, district)
        
        if commodities:
            commodity_records = []
            for commodity in commodities:
                commodity_records.extend(self.filter_by_commodity(filtered, commodity))
            return commodity_records
        
        return filtered
    
    def normalize_price(self, price_str):
        """Convert price string to float"""
        try:
            return float(str(price_str).replace(',', '').strip())
        except:
            return 0.0
    
    def process_market_data(self, records):
        """Process raw market data into structured format"""
        processed = []
        
        for r in records:
            try:
                processed.append({
                    'state': r.get('state', r.get('State', '')),
                    'district': r.get('district', r.get('District', '')),
                    'market': r.get('market', r.get('Market', '')),
                    'commodity': r.get('commodity', r.get('Commodity', '')),
                    'variety': r.get('variety', r.get('Variety', '')),
                    'arrival_date': r.get('arrival_date', r.get('Arrival_Date', '')),
                    'min_price': self.normalize_price(r.get('min_price', r.get('Min_x0020_Price', 0))),
                    'max_price': self.normalize_price(r.get('max_price', r.get('Max_x0020_Price', 0))),
                    'modal_price': self.normalize_price(r.get('modal_price', r.get('Modal_x0020_Price', 0))),
                })
            except Exception as e:
                continue
        
        return processed


# Singleton instance
data_gov_service = DataGovService()
