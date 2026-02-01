from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Crop, FertilizationPlan, IrrigationSchedule, DiseaseDetection, HarvestPrediction, PricePrediction, AgentLog
from sqlalchemy import func

bp = Blueprint('dashboard', __name__)

@bp.route('/', methods=['GET'])
@jwt_required()
def get_dashboard():
    """Aggregated dashboard with all agent recommendations"""
    user_id = int(get_jwt_identity())
    
    # Get all user crops
    crops = Crop.query.filter_by(user_id=user_id).all()
    
    # Aggregate agent data
    dashboard_data = {
        'total_crops': len(crops),
        'crops': [],
        'upcoming_actions': [],
        'alerts': [],
        'agent_insights': {}
    }
    
    for crop in crops:
        crop_data = crop.to_dict()
        
        # Fertilization
        fert = FertilizationPlan.query.filter_by(crop_id=crop.id).first()
        if fert:
            crop_data['fertilization_cost'] = float(fert.estimated_cost) if fert.estimated_cost else 0
            crop_data['savings_potential'] = float(fert.savings_potential) if fert.savings_potential else 0
        
        # Irrigation
        irrig = IrrigationSchedule.query.filter_by(crop_id=crop.id).first()
        if irrig and irrig.agent_schedule:
            next_irrigation = irrig.agent_schedule.get('next_irrigation', {})
            if next_irrigation.get('date'):
                dashboard_data['upcoming_actions'].append({
                    'type': 'irrigation',
                    'crop': crop.crop_name,
                    'date': next_irrigation.get('date'),
                    'details': f"Water {next_irrigation.get('water_amount_mm')}mm"
                })
        
        # Disease alerts
        recent_diseases = DiseaseDetection.query.filter_by(crop_id=crop.id)\
            .order_by(DiseaseDetection.detected_at.desc()).limit(1).all()
        for disease in recent_diseases:
            if disease.severity in ['High', 'Severe', 'Moderate']:
                dashboard_data['alerts'].append({
                    'type': 'disease',
                    'severity': disease.severity,
                    'crop': crop.crop_name,
                    'disease': disease.detected_disease,
                    'action_required': 'Apply treatment immediately'
                })
        
        # Harvest predictions
        harvest = HarvestPrediction.query.filter_by(crop_id=crop.id).first()
        if harvest and harvest.predicted_date:
            crop_data['harvest_date'] = harvest.predicted_date.isoformat()
            crop_data['predicted_yield'] = float(harvest.predicted_yield) if harvest.predicted_yield else 0
        
        # Price predictions
        price = PricePrediction.query.filter_by(crop_id=crop.id).first()
        if price:
            crop_data['optimal_selling_date'] = price.optimal_selling_date.isoformat() if price.optimal_selling_date else None
            crop_data['current_price'] = float(price.current_price) if price.current_price else 0
        
        dashboard_data['crops'].append(crop_data)
    
    return jsonify(dashboard_data)


@bp.route('/alerts', methods=['GET'])
@jwt_required()
def get_alerts():
    """AI-generated alerts and notifications"""
    user_id = int(get_jwt_identity())
    
    alerts = []
    
    # Check all crops for time-sensitive actions
    crops = Crop.query.filter_by(user_id=user_id).all()
    
    for crop in crops:
        # Irrigation alerts
        irrig = IrrigationSchedule.query.filter_by(crop_id=crop.id).first()
        if irrig and irrig.agent_schedule:
            if irrig.agent_schedule.get('should_irrigate_now'):
                alerts.append({
                    'priority': 'high',
                    'category': 'irrigation',
                    'crop': crop.crop_name,
                    'message': f"Irrigate {crop.crop_name} today",
                    'details': irrig.agent_schedule.get('next_irrigation')
                })
        
        # Disease alerts
        diseases = DiseaseDetection.query.filter_by(crop_id=crop.id)\
            .order_by(DiseaseDetection.detected_at.desc()).limit(3).all()
        for disease in diseases:
            if disease.severity in ['High', 'Severe']:
                alerts.append({
                    'priority': 'critical',
                    'category': 'disease',
                    'crop': crop.crop_name,
                    'message': f"{disease.detected_disease} detected",
                    'action': disease.treatment_plan
                })
    
    return jsonify({'alerts': alerts})


@bp.route('/analytics', methods=['GET'])
@jwt_required()
def get_analytics():
    """Agent performance metrics and analytics"""
    user_id = int(get_jwt_identity())
    
    # Agent execution stats
    agent_stats = AgentLog.query.filter_by(user_id=user_id)\
        .with_entities(
            AgentLog.agent_type,
            func.count(AgentLog.id).label('total_executions'),
            func.avg(AgentLog.execution_time).label('avg_execution_time'),
            func.sum(func.cast(AgentLog.status == 'success', db.Integer)).label('successful')
        ).group_by(AgentLog.agent_type).all()
    
    analytics = {
        'agent_performance': [
            {
                'agent': stat.agent_type,
                'total_runs': stat.total_executions,
                'avg_time_seconds': round(float(stat.avg_execution_time or 0), 3),
                'success_rate': round((stat.successful / stat.total_executions * 100) if stat.total_executions > 0 else 0, 1)
            } for stat in agent_stats
        ]
    }
    
    return jsonify(analytics)
