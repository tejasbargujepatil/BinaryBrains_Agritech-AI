from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import IrrigationSchedule, Crop, User
from app.agents import irrigation_agent
from datetime import datetime

bp = Blueprint('irrigation', __name__)

@bp.route('/<int:crop_id>', methods=['GET'])
@jwt_required()
def get_irrigation_schedule(crop_id):
    """Get agent-generated irrigation schedule"""
    user_id = int(get_jwt_identity())
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    schedule = IrrigationSchedule.query.filter_by(crop_id=crop_id).first()
    
    if not schedule:
        return jsonify({'error': 'No irrigation schedule found'}), 404
    
    return jsonify(schedule.to_dict())


@bp.route('/update-moisture', methods=['POST'])
@jwt_required()
def update_soil_moisture():
    """Update soil moisture → Agent auto-adjusts schedule"""
    user_id = int(get_jwt_identity())
    data = request.get_json()
    
    crop_id = data.get('crop_id')
    soil_moisture = data.get('soil_moisture')
    
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    user = User.query.get(user_id)
    location = {
        'latitude': float(user.latitude) if user.latitude else 0,
        'longitude': float(user.longitude) if user.longitude else 0
    }
    
    # Agent re-calculates schedule with new moisture data
    new_schedule = irrigation_agent.run(
        user_id=user_id,
        crop_id=crop_id,
        crop_name=crop.crop_name,
        growth_stage=crop.current_stage or 'vegetative',
        soil_moisture=soil_moisture,
        irrigation_type=crop.irrigation_type or 'drip',
        location=location
    )
    
    # Update existing schedule
    schedule = IrrigationSchedule.query.filter_by(crop_id=crop_id).first()
    if schedule:
        schedule.agent_schedule = new_schedule
        schedule.water_requirement = new_schedule.get('next_irrigation', {}).get('water_amount_mm')
        schedule.optimal_times = new_schedule.get('next_7_days_schedule')
        schedule.updated_at = datetime.utcnow()
        db.session.commit()
    
    return jsonify({
        'message': 'Agent adjusted irrigation schedule based on new soil moisture',
        'schedule': new_schedule
    })
