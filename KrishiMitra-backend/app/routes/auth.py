from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, create_refresh_token, jwt_required, get_jwt_identity
from app import db
from app.models import User

bp = Blueprint('auth', __name__)

@bp.route('/register', methods=['POST'])
def register():
    """Register a new user"""
    data = request.get_json()
    
    # Accept both camelCase (frontend) and snake_case formats
    mobile_number = data.get('mobileNumber') or data.get('mobile_number')
    password = data.get('password')
    name = data.get('name')
    location_data = data.get('location', {})
    
    # Validate input
    if not mobile_number or not password or not name:
        return jsonify({'error': 'Missing required fields'}), 400
    
    # Check if user exists
    if User.query.filter_by(mobile_number=mobile_number).first():
        return jsonify({'error': 'Mobile number already registered'}), 409
    
    # Extract location data (handle nested location object from frontend)
    latitude = location_data.get('latitude') if isinstance(location_data, dict) else data.get('latitude')
    longitude = location_data.get('longitude') if isinstance(location_data, dict) else data.get('longitude')
    address = location_data.get('address') if isinstance(location_data, dict) else data.get('location')
    
    # Create new user
    user = User(
        mobile_number=mobile_number,
        name=name,
        location=address,
        latitude=latitude,
        longitude=longitude
    )
    user.set_password(password)
    
    db.session.add(user)
    db.session.commit()
    
    # Generate tokens
    access_token = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))
    
    # Return response with camelCase for frontend compatibility
    user_dict = user.to_dict()
    return jsonify({
        'message': 'Registration successful',
        'user': user_dict,
        'token': access_token,  # Frontend expects 'token'
        'access_token': access_token,
        'refresh_token': refresh_token
    }), 201


@bp.route('/login', methods=['POST'])
def login():
    """Login user"""
    data = request.get_json()
    
    # Accept both camelCase (frontend) and snake_case formats
    mobile_number = data.get('mobileNumber') or data.get('mobile_number')
    password = data.get('password')
    
    if not mobile_number or not password:
        return jsonify({'error': 'Missing credentials'}), 400
    
    user = User.query.filter_by(mobile_number=mobile_number).first()
    
    if not user or not user.check_password(password):
        return jsonify({'error': 'Invalid credentials'}), 401
    
    access_token = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))
    
    # Return response with camelCase for frontend compatibility
    user_dict = user.to_dict()
    return jsonify({
        'message': 'Login successful',
        'user': user_dict,
        'token': access_token,  # Frontend expects 'token'
        'access_token': access_token,
        'refresh_token': refresh_token
    })


@bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile"""
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    return jsonify(user.to_dict())


@bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update user profile"""
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    data = request.get_json()
    
    if 'name' in data:
        user.name = data['name']
    if 'location' in data:
        user.location = data['location']
    if 'latitude' in data:
        user.latitude = data['latitude']
    if 'longitude' in data:
        user.longitude = data['longitude']
    
    db.session.commit()
    
    return jsonify({
        'message': 'Profile updated',
        'user': user.to_dict()
    })


@bp.route('/verify', methods=['GET', 'POST'])
@jwt_required()
def verify_token():
    """Verify JWT token and return user data"""
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    return jsonify({
        'valid': True,
        'user': user.to_dict()
    })
