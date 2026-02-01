from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import Crop, User, FertilizationPlan, IrrigationSchedule, HarvestPrediction, PricePrediction
from app.agents import (crop_planning_agent, fertilization_agent, irrigation_agent,
                        harvest_prediction_agent, price_prediction_agent)
from datetime import datetime

bp = Blueprint('crops', __name__)

@bp.route('/auto-plan', methods=['POST'])
@jwt_required()
def auto_plan_crop():
    """Agent automatically plans best crop for user"""
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    # Get user's soil data
    soil_data = request.get_json().get('soil_data', {})
    preferences = request.get_json().get('preferences', {})
    
    location = {
        'latitude': float(user.latitude) if user.latitude else 0,
        'longitude': float(user.longitude) if user.longitude else 0,
        'location_name': user.location or 'India'
    }
    
    # Run Crop Planning Agent
    recommendations = crop_planning_agent.run(
        user_id=user_id,
        soil_data=soil_data,
        location=location,
        user_preferences=preferences
    )
    
    return jsonify({
        'message': 'Agent analyzed your farm conditions',
        'recommendations': recommendations
    })


@bp.route('/add', methods=['POST'])
@jwt_required()
def add_crop():
    """Add crop and trigger all agents automatically"""
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    data = request.get_json()
    
    # Create crop
    crop = Crop(
        user_id=user_id,
        crop_name=data['crop_name'],
        crop_variety=data.get('crop_variety'),
        sowing_date=datetime.fromisoformat(data['sowing_date']),
        land_area=data['land_area'],
        area_unit=data.get('area_unit', 'acres'),
        irrigation_type=data.get('irrigation_type'),
        current_stage='sowing',
        health_status='good'
    )
    
    db.session.add(crop)
    db.session.commit()
    
    # Trigger all agents automatically
    agent_results = {}
    
    # 1. Fertilization Agent
    try:
        fert_plan = fertilization_agent.run(
            user_id=user_id,
            crop_id=crop.id,
            crop_name=crop.crop_name,
            current_soil_npk=data.get('soil_npk', {'nitrogen': 0, 'phosphorus': 0, 'potassium': 0}),
            growth_stage='sowing',
            land_area=float(crop.land_area)
        )
        
        # Save fertilization plan
        fertilization = FertilizationPlan(
            crop_id=crop.id,
            agent_plan=fert_plan,
            npk_requirement=fert_plan.get('npk_requirement'),
            recommended_fertilizers=fert_plan.get('fertilizer_plan'),
            cheaper_alternatives=fert_plan.get('cheaper_alternatives'),
            estimated_cost=fert_plan.get('total_cost_per_acre'),
            savings_potential=fert_plan.get('potential_savings')
        )
        db.session.add(fertilization)
        agent_results['fertilization'] = 'success'
    except Exception as e:
        agent_results['fertilization'] = f'error: {str(e)}'
    
    # 2. Irrigation Agent
    try:
        location = {
            'latitude': float(user.latitude) if user.latitude else 0,
            'longitude': float(user.longitude) if user.longitude else 0
        }
        
        irrigation_schedule = irrigation_agent.run(
            user_id=user_id,
            crop_id=crop.id,
            crop_name=crop.crop_name,
            growth_stage='sowing',
            soil_moisture=data.get('soil_moisture', 50),
            irrigation_type=crop.irrigation_type or 'drip',
            location=location
        )
        
        # Save irrigation schedule
        irrigation = IrrigationSchedule(
            crop_id=crop.id,
            agent_schedule=irrigation_schedule,
            water_requirement=irrigation_schedule.get('next_irrigation', {}).get('water_amount_mm'),
            optimal_times=irrigation_schedule.get('next_7_days_schedule')
        )
        db.session.add(irrigation)
        agent_results['irrigation'] = 'success'
    except Exception as e:
        agent_results['irrigation'] = f'error: {str(e)}'
    
    # 3. Harvest Prediction Agent
    try:
        harvest_pred = harvest_prediction_agent.run(
            user_id=user_id,
            crop_id=crop.id,
            crop_name=crop.crop_name,
            sowing_date=crop.sowing_date.isoformat(),
            growth_data={'days_since_sowing': 0, 'current_stage': 'sowing', 'health_status': 'good'}
        )
        
        # Save harvest prediction
        harvest = HarvestPrediction(
            crop_id=crop.id,
            predicted_yield=harvest_pred.get('yield_prediction', {}).get('estimated_yield_per_acre'),
            yield_unit=harvest_pred.get('yield_prediction', {}).get('unit'),
            predicted_date=datetime.fromisoformat(harvest_pred.get('predicted_harvest_date')) if harvest_pred.get('predicted_harvest_date') else None,
            agent_analysis=harvest_pred,
            confidence_level=harvest_pred.get('confidence_level')
        )
        db.session.add(harvest)
        agent_results['harvest_prediction'] = 'success'
    except Exception as e:
        agent_results['harvest_prediction'] = f'error: {str(e)}'
    
    # 4. Price Prediction Agent
    try:
        if harvest.predicted_date:
            price_pred = price_prediction_agent.run(
                user_id=user_id,
                crop_id=crop.id,
                crop_name=crop.crop_name,
                harvest_date=harvest.predicted_date.isoformat()
            )
            
            # Save price prediction
            price = PricePrediction(
                crop_id=crop.id,
                crop_name=crop.crop_name,
                current_price=price_pred.get('current_price_analysis', {}).get('current_price_per_quintal'),
                predicted_prices=price_pred.get('price_predictions'),
                optimal_selling_date=datetime.fromisoformat(price_pred.get('selling_strategy', {}).get('optimal_selling_date')) if price_pred.get('selling_strategy', {}).get('optimal_selling_date') else None,
                market_trends=price_pred.get('market_insights'),
                agent_recommendations=price_pred,
                confidence_score=price_pred.get('price_predictions', {}).get('2_weeks', {}).get('confidence')
            )
            db.session.add(price)
            agent_results['price_prediction'] = 'success'
    except Exception as e:
        agent_results['price_prediction'] = f'error: {str(e)}'
    
    db.session.commit()
    
    return jsonify({
        'message': 'Crop added successfully! All agents activated.',
        'crop': crop.to_dict(include_agents=True),
        'agent_execution': agent_results
    }), 201


@bp.route('/', methods=['GET'])
@jwt_required()
def get_crops():
    """Get all user crops with agent status"""
    user_id = int(get_jwt_identity())
    crops = Crop.query.filter_by(user_id=user_id).all()
    
    return jsonify({
        'crops': [crop.to_dict(include_agents=True) for crop in crops]
    })


@bp.route('/<int:crop_id>', methods=['GET'])
@jwt_required()
def get_crop(crop_id):
    """Get single crop with all agent data"""
    user_id = int(get_jwt_identity())
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    return jsonify({'crop': crop.to_dict(include_agents=True)})


@bp.route('/<int:crop_id>', methods=['DELETE'])
@jwt_required()
def delete_crop(crop_id):
    """Delete crop"""
    user_id = int(get_jwt_identity())
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    db.session.delete(crop)
    db.session.commit()
    
    return jsonify({'message': 'Crop deleted successfully'})
