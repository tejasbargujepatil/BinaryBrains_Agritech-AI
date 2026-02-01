from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename
from app import db
from app.models import FertilizationPlan, Crop
from app.agents import fertilization_agent
import os

bp = Blueprint('fertilization', __name__)

@bp.route('/<int:crop_id>', methods=['GET'])
@jwt_required()
def get_fertilization_plan(crop_id):
    """Get agent-generated fertilization plan for crop"""
    user_id = int(get_jwt_identity())
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    plan = FertilizationPlan.query.filter_by(crop_id=crop_id).first()
    
    if not plan:
        return jsonify({'error': 'No fertilization plan found'}), 404
    
    return jsonify(plan.to_dict())


@bp.route('/alternatives', methods=['POST'])
@jwt_required()
def find_cheaper_alternatives():
    """Agent finds cheaper fertilizer alternatives from bill upload"""
    data = request.get_json()
    
    current_fertilizer = {
        'brand': data.get('brand', 'Unknown'),
        'npk': data.get('npk', '0-0-0'),
        'price': data.get('price', 0)
    }
    
    # Run Fertilization Agent to find alternatives
    alternatives = fertilization_agent.find_cheaper_alternatives(current_fertilizer)
    
    return jsonify({
        'message': 'Agent found cheaper alternatives',
        'alternatives': alternatives
    })


@bp.route('/analyze-bill', methods=['POST'])
@jwt_required()
def analyze_fertilizer_bill():
    """OCR + Agent analysis of fertilizer bill"""
    # In production, integrate with OCR service
    # For now, accept manual NPK input
    
    data = request.get_json()
    npk_values = data.get('npk', {})
    
    fertilizer_data = {
        'npk': f"{npk_values.get('n', 0)}-{npk_values.get('p', 0)}-{npk_values.get('k', 0)}",
        'price': data.get('price', 0),
        'brand': data.get('brand', 'Unknown')
    }
    
    alternatives = fertilization_agent.find_cheaper_alternatives(fertilizer_data)
    
    return jsonify({
        'message': 'Bill analyzed successfully',
        'extracted_npk': npk_values,
        'cheaper_alternatives': alternatives
    })
