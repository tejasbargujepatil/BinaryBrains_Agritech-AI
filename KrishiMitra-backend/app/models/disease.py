from app import db
from datetime import datetime
from sqlalchemy import JSON

class DiseaseDetection(db.Model):
    """Agent-detected diseases from images"""
    __tablename__ = 'disease_detections'
    
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id', ondelete='CASCADE'), nullable=False)
    image_url = db.Column(db.String(500))
    detected_disease = db.Column(db.String(200))
    confidence_score = db.Column(db.Numeric(5, 2))
    severity = db.Column(db.String(20))
    agent_diagnosis = db.Column(JSON)  # Disease Detection Agent output
    treatment_plan = db.Column(JSON)
    preventive_measures = db.Column(JSON)
    detected_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'crop_id': self.crop_id,
            'image_url': self.image_url,
            'detected_disease': self.detected_disease,
            'confidence_score': float(self.confidence_score) if self.confidence_score else None,
            'severity': self.severity,
            'agent_diagnosis': self.agent_diagnosis,
            'treatment_plan': self.treatment_plan,
            'preventive_measures': self.preventive_measures,
            'detected_at': self.detected_at.isoformat() if self.detected_at else None
        }
    
    def __repr__(self):
        return f'<DiseaseDetection {self.detected_disease} - Crop {self.crop_id}>'


class HarvestPrediction(db.Model):
    """Agent-predicted harvest data"""
    __tablename__ = 'harvest_predictions'
    
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id', ondelete='CASCADE'), nullable=False)
    predicted_yield = db.Column(db.Numeric(10, 2))
    yield_unit = db.Column(db.String(20))
    predicted_date = db.Column(db.Date)
    quality_grade = db.Column(db.String(20))
    market_readiness = db.Column(JSON)
    agent_analysis = db.Column(JSON)  # Harvest Prediction Agent output
    confidence_level = db.Column(db.Numeric(5, 2))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'crop_id': self.crop_id,
            'predicted_yield': float(self.predicted_yield) if self.predicted_yield else None,
            'yield_unit': self.yield_unit,
            'predicted_date': self.predicted_date.isoformat() if self.predicted_date else None,
            'quality_grade': self.quality_grade,
            'market_readiness': self.market_readiness,
            'agent_analysis': self.agent_analysis,
            'confidence_level': float(self.confidence_level) if self.confidence_level else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self):
        return f'<HarvestPrediction Crop {self.crop_id} - {self.predicted_date}>'


class PricePrediction(db.Model):
    """Agent-predicted market prices"""
    __tablename__ = 'price_predictions'
    
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id', ondelete='CASCADE'), nullable=False)
    crop_name = db.Column(db.String(100))
    current_price = db.Column(db.Numeric(10, 2))
    predicted_prices = db.Column(JSON)  # Price trends over time
    optimal_selling_date = db.Column(db.Date)
    market_trends = db.Column(JSON)
    agent_recommendations = db.Column(JSON)  # Price Prediction Agent output
    confidence_score = db.Column(db.Numeric(5, 2))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'crop_id': self.crop_id,
            'crop_name': self.crop_name,
            'current_price': float(self.current_price) if self.current_price else None,
            'predicted_prices': self.predicted_prices,
            'optimal_selling_date': self.optimal_selling_date.isoformat() if self.optimal_selling_date else None,
            'market_trends': self.market_trends,
            'agent_recommendations': self.agent_recommendations,
            'confidence_score': float(self.confidence_score) if self.confidence_score else None,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
    
    def __repr__(self):
        return f'<PricePrediction {self.crop_name} - ₹{self.current_price}>'


class AgentLog(db.Model):
    """Log all agent executions for monitoring"""
    __tablename__ = 'agent_logs'
    
    id = db.Column(db.Integer, primary_key=True)
    agent_type = db.Column(db.String(100), nullable=False, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'))
    action = db.Column(db.String(200))
    input_data = db.Column(JSON)
    output_data = db.Column(JSON)
    status = db.Column(db.String(20))  # success, error, partial
    execution_time = db.Column(db.Numeric(10, 3))  # in seconds
    created_at = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'agent_type': self.agent_type,
            'action': self.action,
            'status': self.status,
            'execution_time': float(self.execution_time) if self.execution_time else None,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
    
    def __repr__(self):
        return f'<AgentLog {self.agent_type} - {self.status}>'
