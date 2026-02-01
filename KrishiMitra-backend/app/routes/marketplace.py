from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.agents import fertilization_agent
from app.agents.price_analysis_agent import price_analysis_agent
from app.services.data_gov_service import data_gov_service
from app.models import User

bp = Blueprint('marketplace', __name__)

@bp.route('/fertilizers/compare', methods=['POST'])
@jwt_required()
def compare_fertilizers():
    """Find cheaper fertilizer alternatives - Marketplace feature"""
    data = request.get_json()
    
    # Accept NPK from bill or manual input
    npk = data.get('npk', {})
    current_brand = data.get('current_brand', 'Unknown')
    current_price = data.get('current_price', 0)
    
    fertilizer_info = {
        'brand': current_brand,
        'npk': f"{npk.get('n', 0)}-{npk.get('p', 0)}-{npk.get('k', 0)}",
        'price': current_price
    }
    
    # Agent finds cheaper alternatives
    alternatives = fertilization_agent.find_cheaper_alternatives(fertilizer_info)
    
    return jsonify({
        'message': 'Krishidnya AI found cheaper alternatives',
        'current_fertilizer': fertilizer_info,
        'recommendations': alternatives
    })


@bp.route('/crop-prices', methods=['POST'])
@jwt_required()
def get_crop_prices():
    """Get crop prices from data.gov.in for specific crops and location"""
    data = request.get_json()
    
    state = data.get('state', '')
    district = data.get('district', '')
    commodities = data.get('commodities', [])  # List of crop names
    
    if not state or not district:
        return jsonify({'error': 'State and district required'}), 400
    
    try:
        # Fetch market data
        markets = data_gov_service.get_nearby_markets(state, district, commodities)
        processed = data_gov_service.process_market_data(markets)
        
        return jsonify({
            'state': state,
            'district': district,
            'commodities': commodities,
            'markets_found': len(processed),
            'markets': processed[:50]  # Limit to 50 results
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@bp.route('/nearby-markets', methods=['GET'])
@jwt_required()
def get_nearby_markets():
    """Get nearby markets with prices based on user location"""
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    # Get optional filters
    commodity = request.args.get('commodity', None)
    state = request.args.get('state', None)
    district = request.args.get('district', None)
    
    try:
        # Use user's location to determine state/district if not provided
        # For now, fetch all and filter
        commodities = [commodity] if commodity else None
        markets = data_gov_service.get_nearby_markets(state or '', district or '', commodities)
        processed = data_gov_service.process_market_data(markets)
        
        return jsonify({
            'user_location': {
                'latitude': user.latitude,
                'longitude': user.longitude,
                'address': user.address
            },
            'markets': processed[:30]
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@bp.route('/analyze-prices', methods=['POST'])
@jwt_required()
def analyze_crop_prices():
    """AI-powered price analysis for user's crops"""
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    data = request.get_json()
    crop_name = data.get('crop_name', '')
    markets = data.get('markets', [])
    
    if not crop_name or not markets:
        return jsonify({'error': 'Crop name and markets data required'}), 400
    
    try:
        user_location = {
            'latitude': user.latitude or 0,
            'longitude': user.longitude or 0,
            'address': user.address or 'Unknown'
        }
        
        # Run AI analysis
        analysis = price_analysis_agent.run(
            crop_name=crop_name,
            markets=markets,
            user_location=user_location
        )
        
        return jsonify({
            'crop': crop_name,
            'user_location': user_location,
            'analysis': analysis
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
