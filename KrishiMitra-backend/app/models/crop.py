from app import db
from datetime import datetime
from sqlalchemy import JSON

class Crop(db.Model):
    """Crop model with agent recommendations"""
    __tablename__ = 'crops'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    crop_name = db.Column(db.String(100), nullable=False)
    crop_variety = db.Column(db.String(100))
    sowing_date = db.Column(db.Date, nullable=False)
    land_area = db.Column(db.Numeric(10, 2), nullable=False)
    area_unit = db.Column(db.String(20), default='acres')
    irrigation_type = db.Column(db.String(50))
    current_stage = db.Column(db.String(50))
    health_status = db.Column(db.String(20))
    agent_recommendations = db.Column(JSON)  # All agent data
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    fertilization_plans = db.relationship('FertilizationPlan', backref='crop', lazy='dynamic', cascade='all, delete-orphan')
    irrigation_schedules = db.relationship('IrrigationSchedule', backref='crop', lazy='dynamic', cascade='all, delete-orphan')
    disease_detections = db.relationship('DiseaseDetection', backref='crop', lazy='dynamic', cascade='all, delete-orphan')
    harvest_predictions = db.relationship('HarvestPrediction', backref='crop', lazy='dynamic', cascade='all, delete-orphan')
    price_predictions = db.relationship('PricePrediction', backref='crop', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self, include_agents=False):
        """Convert to dictionary"""
        data = {
            'id': self.id,
            'user_id': self.user_id,
            'crop_name': self.crop_name,
            'crop_variety': self.crop_variety,
            'sowing_date': self.sowing_date.isoformat() if self.sowing_date else None,
            'land_area': float(self.land_area),
            'area_unit': self.area_unit,
            'irrigation_type': self.irrigation_type,
            'current_stage': self.current_stage,
            'health_status': self.health_status,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_agents:
            data['agent_recommendations'] = self.agent_recommendations
            data['fertilization'] = self.fertilization_plans.first().to_dict() if self.fertilization_plans.first() else None
            data['irrigation'] = self.irrigation_schedules.first().to_dict() if self.irrigation_schedules.first() else None
            data['harvest_prediction'] = self.harvest_predictions.first().to_dict() if self.harvest_predictions.first() else None
        
        return data
    
    def __repr__(self):
        return f'<Crop {self.crop_name} - User {self.user_id}>'
