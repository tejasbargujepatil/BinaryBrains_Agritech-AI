from app import db
from datetime import datetime
from sqlalchemy import JSON

class SoilData(db.Model):
    """Soil analysis data with agent recommendations"""
    __tablename__ = 'soil_data'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id', ondelete='SET NULL'))
    soil_type = db.Column(db.String(50))
    nitrogen_level = db.Column(db.Numeric(5, 2))
    phosphorus_level = db.Column(db.Numeric(5, 2))
    potassium_level = db.Column(db.Numeric(5, 2))
    ph_level = db.Column(db.Numeric(4, 2))
    organic_carbon = db.Column(db.Numeric(5, 2))
    moisture_level = db.Column(db.Numeric(5, 2))
    agent_analysis = db.Column(JSON)  # Soil Analysis Agent output
    recommendations = db.Column(JSON)  # Agent recommendations
    test_date = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'crop_id': self.crop_id,
            'soil_type': self.soil_type,
            'nitrogen_level': float(self.nitrogen_level) if self.nitrogen_level else None,
            'phosphorus_level': float(self.phosphorus_level) if self.phosphorus_level else None,
            'potassium_level': float(self.potassium_level) if self.potassium_level else None,
            'ph_level': float(self.ph_level) if self.ph_level else None,
            'organic_carbon': float(self.organic_carbon) if self.organic_carbon else None,
            'moisture_level': float(self.moisture_level) if self.moisture_level else None,
            'agent_analysis': self.agent_analysis,
            'recommendations': self.recommendations,
            'test_date': self.test_date.isoformat() if self.test_date else None
        }
    
    def __repr__(self):
        return f'<SoilData User {self.user_id} - {self.test_date}>'


class FertilizationPlan(db.Model):
    """Agent-generated fertilization plans"""
    __tablename__ = 'fertilization_plans'
    
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id', ondelete='CASCADE'), nullable=False)
    agent_plan = db.Column(JSON, nullable=False)  # Complete Fertilization Agent output
    npk_requirement = db.Column(JSON)
    recommended_fertilizers = db.Column(JSON)
    cheaper_alternatives = db.Column(JSON)
    application_schedule = db.Column(JSON)
    estimated_cost = db.Column(db.Numeric(10, 2))
    savings_potential = db.Column(db.Numeric(10, 2))
    created_by_agent = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'crop_id': self.crop_id,
            'agent_plan': self.agent_plan,
            'npk_requirement': self.npk_requirement,
            'recommended_fertilizers': self.recommended_fertilizers,
            'cheaper_alternatives': self.cheaper_alternatives,
            'application_schedule': self.application_schedule,
            'estimated_cost': float(self.estimated_cost) if self.estimated_cost else None,
            'savings_potential': float(self.savings_potential) if self.savings_potential else None,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
    
    def __repr__(self):
        return f'<FertilizationPlan Crop {self.crop_id}>'


class IrrigationSchedule(db.Model):
    """Agent-generated irrigation schedules"""
    __tablename__ = 'irrigation_schedules'
    
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id', ondelete='CASCADE'), nullable=False)
    agent_schedule = db.Column(JSON, nullable=False)  # Irrigation Agent output
    water_requirement = db.Column(db.Numeric(10, 2))
    frequency = db.Column(db.String(50))
    optimal_times = db.Column(JSON)
    weather_adjustments = db.Column(JSON)
    soil_moisture_thresholds = db.Column(JSON)
    auto_adjusted = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'crop_id': self.crop_id,
            'agent_schedule': self.agent_schedule,
            'water_requirement': float(self.water_requirement) if self.water_requirement else None,
            'frequency': self.frequency,
            'optimal_times': self.optimal_times,
            'weather_adjustments': self.weather_adjustments,
            'soil_moisture_thresholds': self.soil_moisture_thresholds,
            'auto_adjusted': self.auto_adjusted,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self):
        return f'<IrrigationSchedule Crop {self.crop_id}>'
