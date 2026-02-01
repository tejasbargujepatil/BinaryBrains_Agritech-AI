from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.agent_orchestrator import orchestrator
from app.models import User, Crop
from app.services.stage_manager import stage_manager
from app.agents.irrigation_agent import IrrigationAgent
import logging

bp = Blueprint('agents', __name__)
logger = logging.getLogger(__name__)

@bp.route('/analyze', methods=['POST'])
@jwt_required()
def analyze_crop_comprehensive():
    """
    Execute multi-agent comprehensive analysis for a crop.
    
    Expected JSON Input:
    {
        "crop_name": "Cotton",
        "soil_data": {"nitrogen": 40, "phosphorus": 30, "potassium": 20, "ph": 7.0},
        "location": {"latitude": 20.0, "longitude": 75.0, "location_name": "Aurangabad"},
        "growth_stage": "vegetative",
        "land_area": 2.5,
        "soil_moisture": 45,
        "irrigation_type": "drip",
        "sowing_date": "2024-06-15",
        "symptoms": "yellowing leaves" (optional)
    }
    """
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
            
        data = request.get_json()
        crop_name = data.get('crop_name')
        
        if not crop_name:
            return jsonify({'error': 'crop_name is required'}), 400
            
        # Enrich location if not provided fully
        location = data.get('location', {})
        if not location.get('latitude') or not location.get('longitude'):
            location['latitude'] = float(user.latitude) if user.latitude else 0
            location['longitude'] = float(user.longitude) if user.longitude else 0
        if not location.get('location_name'):
            location['location_name'] = user.location or 'India'
            
        # Prepare analysis data
        analysis_input = {
            "soil_data": data.get('soil_data'),
            "location": location,
            "soil_npk": data.get('soil_data'), # Fertilization uses soil_npk key
            "growth_stage": data.get('growth_stage', 'vegetative'),
            "land_area": data.get('land_area', 1.0),
            "soil_moisture": data.get('soil_moisture'),
            "irrigation_type": data.get('irrigation_type'),
            "sowing_date": data.get('sowing_date'),
            "growth_data": {
                "health_status": "Good",
                "current_stage": data.get('growth_stage', 'vegetative')
            },
            "user_preferences": data.get('preferences'),
            "user_context": {
                "user_name": user.name,
                "location": location.get('location_name')
            }
        }
        
        # Add symptom data if present
        if data.get('symptoms'):
            # This requires manual handling as it's not standard in orchestrator.comprehensive_analysis input dict
            # We can handle it by calling the disease agent specifically in the orchestrator
            # For now, let's assume the orchestrator might be updated or we handle it separately
            # Actually, looking at orchestrator, it doesn't take 'symptoms' in comprehensive_analysis args directly
            # but creates 'results' dict.
            # Let's run comprehensively.
            pass

        # Execute orchestrator
        results = orchestrator.comprehensive_analysis(
            crop_name=crop_name,
            analysis_data=analysis_input,
            summarize=True
        )
        
        # If symptoms provided, manually run disease agent and add to results
        if data.get('symptoms'):
            disease_result = orchestrator.analyze_disease(
                crop_name=crop_name,
                symptoms=data.get('symptoms'),
                summarize=True
            )
            results['disease_detection'] = disease_result
            results['agents_executed'].append('disease_detection')
            
        return jsonify({
            'status': 'success',
            'data': results
        })
        
    except Exception as e:
        logger.error(f"Analysis endpoint failed: {str(e)}")
        return jsonify({'error': str(e)}), 500

@bp.route('/daily_check', methods=['POST'])
@jwt_required()
def run_daily_check():
    """
    Trigger proactive daily checks for all user crops.
    Updates growth stages & generates continuous guidance alerts.
    """
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
            
        crops = Crop.query.filter_by(user_id=user_id).all()
        alerts = []
        updated_stages = []
        
        irrigation_agent = IrrigationAgent()
        
        for crop in crops:
            # 1. Update Growth Stage
            if crop.sowing_date:
                stage_info = stage_manager.calculate_current_stage(crop.crop_name, crop.sowing_date)
                new_stage = stage_info.get("stage")
                
                # Check if stage changed
                if new_stage and new_stage != crop.current_stage:
                    crop.current_stage = new_stage
                    updated_stages.append({
                        "crop": crop.crop_name,
                        "old_stage": crop.current_stage,
                        "new_stage": new_stage
                    })
                    # Add Stage Change Alert
                    alerts.append({
                        "type": "stage_update",
                        "severity": "low",
                        "message": f"{crop.crop_name} is now in {new_stage} stage.",
                        "crop_id": crop.id
                    })
            
            # 2. Run Contextual Agent Checks
            # Construct location
            location = {
                "latitude": float(user.latitude) if user.latitude else 0,
                "longitude": float(user.longitude) if user.longitude else 0,
                "location_name": user.location or "India"
            }
            
            # Check Irrigation
            try:
                irrig_alert = irrigation_agent.check_daily_status(
                    crop_name=crop.crop_name,
                    growth_stage=crop.current_stage or "Vegetative",
                    sowing_date=crop.sowing_date,
                    location=location
                )
                if irrig_alert:
                    irrig_alert['crop_id'] = crop.id
                    alerts.append(irrig_alert)
            except Exception as e:
                logger.warning(f"Irrigation check failed for {crop.crop_name}: {e}")

        # FORCE TEST ALERT (Debugging)
        if not alerts:
            alerts.append({
                "type": "test_alert",
                "severity": "info",
                "message": "System Check: Continuous guidance is active.",
                "icon": "verified"
            })

        # Commit stage updates
        from app import db
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'alerts': alerts,
            'stage_updates': updated_stages
        })

    except Exception as e:
        logger.error(f"Daily check failed: {str(e)}")
        return jsonify({'error': str(e)}), 500
