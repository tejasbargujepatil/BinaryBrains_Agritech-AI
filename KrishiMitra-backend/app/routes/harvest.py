from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import HarvestPrediction, PricePrediction, Crop

bp = Blueprint('harvest', __name__)

@bp.route('/predict/<int:crop_id>', methods=['GET'])
@jwt_required()
def predict_harvest(crop_id):
    """Agent predicts harvest date and yield"""
    user_id = int(get_jwt_identity())
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    prediction = HarvestPrediction.query.filter_by(crop_id=crop_id).first()
    
    if not prediction:
        return jsonify({'error': 'No harvest prediction available'}), 404
    
    return jsonify(prediction.to_dict())


@bp.route('/recommendations/<int:crop_id>', methods=['GET'])
@jwt_required()
def get_harvest_recommendations(crop_id):
    """Get agent recommendations for harvest timing"""
    user_id = int(get_jwt_identity())
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    harvest_pred = HarvestPrediction.query.filter_by(crop_id=crop_id).first()
    price_pred = PricePrediction.query.filter_by(crop_id=crop_id).first()
    
    return jsonify({
        'crop': crop.to_dict(),
        'harvest_prediction': harvest_pred.to_dict() if harvest_pred else None,
        'price_prediction': price_pred.to_dict() if price_pred else None,
        'combined_recommendation': {
            'optimal_harvest_date': harvest_pred.predicted_date.isoformat() if harvest_pred and harvest_pred.predicted_date else None,
            'optimal_selling_date': price_pred.optimal_selling_date.isoformat() if price_pred and price_pred.optimal_selling_date else None,
            'strategy': 'Harvest on predicted date, store if needed, sell when prices peak'
        }
    })
