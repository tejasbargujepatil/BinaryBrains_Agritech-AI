from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import DiseaseDetection, Crop
from app.agents import disease_detection_agent
from datetime import datetime

bp = Blueprint('disease', __name__)

@bp.route('/detect', methods=['POST'])
@jwt_required()
def detect_disease():
    """Upload image → Agent detects disease and recommends treatment"""
    user_id = int(get_jwt_identity())
    data = request.get_json()
    
    crop_id = data.get('crop_id')
    symptoms = data.get('symptoms', '')
    image_url = data.get('image_url')  # In production, handle actual file upload
    
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    # Run Disease Detection Agent
    diagnosis = disease_detection_agent.run(
        user_id=user_id,
        crop_id=crop_id,
        crop_name=crop.crop_name,
        symptoms=symptoms,
        image_analysis=data.get('image_analysis')
    )
    
    # Save detection
    detection = DiseaseDetection(
        crop_id=crop_id,
        image_url=image_url,
        detected_disease=diagnosis.get('disease_name'),
        confidence_score=diagnosis.get('confidence_score'),
        severity=diagnosis.get('severity'),
        agent_diagnosis=diagnosis,
        treatment_plan=diagnosis.get('chemical_treatment'),
        preventive_measures=diagnosis.get('preventive_measures')
    )
    
    db.session.add(detection)
    
    # Update crop health status
    if diagnosis.get('severity') in ['High', 'Severe']:
        crop.health_status = 'poor'
    elif diagnosis.get('severity') == 'Moderate':
        crop.health_status = 'fair'
    
    db.session.commit()
    
    return jsonify({
        'message': 'Agent analyzed disease successfully',
        'diagnosis': diagnosis
    }), 201


@bp.route('/<int:crop_id>', methods=['GET'])
@jwt_required()
def get_crop_diseases(crop_id):
    """Get all disease detections for a crop"""
    user_id = int(get_jwt_identity())
    crop = Crop.query.filter_by(id=crop_id, user_id=user_id).first()
    
    if not crop:
        return jsonify({'error': 'Crop not found'}), 404
    
    detections = DiseaseDetection.query.filter_by(crop_id=crop_id).all()
    
    return jsonify({
        'crop': crop.to_dict(),
        'detections': [d.to_dict() for d in detections]
    })
