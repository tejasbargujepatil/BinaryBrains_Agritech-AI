from flask import Blueprint, request, jsonify
from app.services.soil_service import soil_service

bp = Blueprint('soil', __name__)

@bp.route('', methods=['GET'])
def get_soil():
    """Get soil data for coordinates"""
    try:
        lat = float(request.args.get('lat', 0))
        lon = float(request.args.get('lon', 0))
        
        if lat == 0 or lon == 0:
            return jsonify({'error': 'Missing or invalid coordinates'}), 400
        
        soil_data = soil_service.get_soil_data(lat, lon)
        return jsonify(soil_data), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
