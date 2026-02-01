from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from app.config import config
import os

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()

def create_app(config_name=None):
    """Application factory pattern"""
    if config_name is None:
        config_name = os.getenv('FLASK_ENV', 'development')
    
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    CORS(app)
    
    # Register blueprints
    from app.routes import auth, crops, fertilization, irrigation, disease, harvest, marketplace, dashboard, weather, soil
    
    app.register_blueprint(auth.bp, url_prefix='/api/auth')
    app.register_blueprint(crops.bp, url_prefix='/api/crops')
    app.register_blueprint(fertilization.bp, url_prefix='/api/fertilization')
    app.register_blueprint(irrigation.bp, url_prefix='/api/irrigation')
    app.register_blueprint(disease.bp, url_prefix='/api/disease')
    app.register_blueprint(harvest.bp, url_prefix='/api/harvest')
    app.register_blueprint(marketplace.bp, url_prefix='/api/marketplace')
    app.register_blueprint(dashboard.bp, url_prefix='/api/dashboard')
    app.register_blueprint(weather.bp, url_prefix='/weather')
    app.register_blueprint(soil.bp, url_prefix='/soil')
    
    from app.routes import agents
    app.register_blueprint(agents.bp, url_prefix='/api/v1/agent')
    
    # Health check endpoint
    @app.route('/health', methods=['GET'])
    def health_check():
        return {'status': 'healthy', 'service': 'KrishiMitra Agentic Backend'}, 200
    
    return app
