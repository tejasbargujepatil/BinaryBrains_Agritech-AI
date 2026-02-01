from flask import Blueprint, request, jsonify
from app.services.weather_service import weather_service

bp = Blueprint('weather', __name__)

@bp.route('', methods=['GET'])
def get_weather():
    """Get weather data for coordinates"""
    try:
        lat = float(request.args.get('lat', 0))
        lon = float(request.args.get('lon', 0))
        
        if lat == 0 or lon == 0:
            return jsonify({'error': 'Missing or invalid coordinates'}), 400
        
        weather = weather_service.get_current_weather(lat, lon)
        return jsonify(weather), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/forecast', methods=['GET'])
def get_forecast():
    """Get weather forecast for coordinates"""
    try:
        lat = float(request.args.get('lat', 0))
        lon = float(request.args.get('lon', 0))
        days = int(request.args.get('days', 7))
        
        if lat == 0 or lon == 0:
            return jsonify({'error': 'Missing or invalid coordinates'}), 400
        
        forecast = weather_service.get_forecast(lat, lon, days)
        return jsonify(forecast), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
