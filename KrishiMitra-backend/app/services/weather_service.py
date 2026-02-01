import requests
from app.config import Config
from datetime import datetime, timedelta

class WeatherService:
    """Service for fetching weather data from OpenWeatherMap"""
    
    def __init__(self):
        self.api_key = Config.OPENWEATHER_API_KEY
        self.base_url = "https://api.openweathermap.org/data/2.5"
    
    def get_current_weather(self, lat: float, lon: float) -> dict:
        """Get current weather for coordinates"""
        try:
            url = f"{self.base_url}/weather"
            params = {
                'lat': lat,
                'lon': lon,
                'appid': self.api_key,
                'units': 'metric'
            }
            response = requests.get(url, params=params)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            raise Exception(f"Weather API error: {str(e)}")
    
    def get_forecast(self, lat: float, lon: float, days: int = 7) -> dict:
        """Get weather forecast for coordinates"""
        try:
            url = f"{self.base_url}/forecast"
            params = {
                'lat': lat,
                'lon': lon,
                'appid': self.api_key,
                'units': 'metric',
                'cnt': days * 8  # 3-hour intervals
            }
            response = requests.get(url, params=params)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            raise Exception(f"Weather forecast error: {str(e)}")
    
    def analyze_for_irrigation(self, lat: float, lon: float) -> dict:
        """Analyze weather for irrigation decision"""
        forecast = self.get_forecast(lat, lon, days=3)
        
        rain_expected = False
        total_rainfall = 0
        
        for item in forecast.get('list', [])[:8]:  # Next 24 hours
            if 'rain' in item:
                rain_expected = True
                total_rainfall += item['rain'].get('3h', 0)
        
        return {
            'rain_expected_24h': rain_expected,
            'total_rainfall_mm': total_rainfall,
            'recommendation': 'skip' if total_rainfall > 10 else 'proceed',
            'forecast_data': forecast
        }


# Singleton instance
weather_service = WeatherService()
