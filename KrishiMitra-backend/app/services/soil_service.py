import requests
from app.config import Config

class SoilService:
    """Service for soil data - using estimated regional data"""
    
    def __init__(self):
        self.api_key = Config.OPENWEATHER_API_KEY
    
    def get_soil_data(self, lat: float, lon: float) -> dict:
        """
        Get soil data for coordinates
        Returns estimated soil NPK and pH based on region
        """
        # Regional soil estimates for India
        # This is a simplified version - ideally use real soil API
        soil_estimates = {
            'maharashtra': {'nitrogen': 45, 'phosphorus': 30, 'potassium': 35, 'ph': 7.2, 'soil_type': 'Black Soil'},
            'karnataka': {'nitrogen': 40, 'phosphorus': 28, 'potassium': 32, 'ph': 6.8, 'soil_type': 'Red Soil'},
            'punjab': {'nitrogen': 55, 'phosphorus': 35, 'potassium': 40, 'ph': 7.5, 'soil_type': 'Alluvial Soil'},
            'default': {'nitrogen': 42, 'phosphorus': 30, 'potassium': 34, 'ph': 7.0, 'soil_type': 'Mixed Soil'}
        }
        
        try:
            # Try to determine region from coordinates using reverse geocoding
            region = self._get_region(lat, lon)
            soil = soil_estimates.get(region.lower(), soil_estimates['default'])
            
            return {
                'coordinates': {'latitude': lat, 'longitude': lon},
                'nitrogen': soil['nitrogen'],
                'phosphorus': soil['phosphorus'],
                'potassium': soil['potassium'],
                'ph': soil['ph'],
                'soil_type': soil['soil_type'],
                'source': 'estimated',
                'note': 'For accurate data, consider soil testing at local agricultural lab'
            }
        except Exception as e:
            # Return default values if anything fails
            return {
                'coordinates': {'latitude': lat, 'longitude': lon},
                'nitrogen': 42,
                'phosphorus': 30,
                'potassium': 34,
                'ph': 7.0,
                'soil_type': 'Mixed Soil',
                'source': 'default',
                'error': str(e)
            }
    
    def _get_region(self, lat: float, lon: float) -> str:
        """Determine region from coordinates"""
        # Simple region mapping based on lat/lon ranges
        # Maharashtra: ~15-22N, 72-80E
        # Karnataka: ~11-18N, 74-78E
        # Punjab: ~29-32N, 74-76E
        
        if 15 <= lat <= 22 and 72 <= lon <= 80:
            return 'maharashtra'
        elif 11 <= lat <= 18 and 74 <= lon <= 78:
            return 'karnataka'
        elif 29 <= lat <= 32 and 74 <= lon <= 76:
            return 'punjab'
        else:
            return 'default'

# Singleton instance
soil_service = SoilService()
