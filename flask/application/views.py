from datetime import datetime, timedelta
import jwt
from flask import Blueprint, jsonify, request

from app import app

from .models import Sensor, User

# creating the sensor blueprint blueprint
sensor_view = Blueprint('sensor_view', __name__)

# creating the login and register blueprint
security_view = Blueprint('security_view', __name__)


# just  for the lulz
@sensor_view.route('/', methods=['GET'])
def lulz():
    return '<h1> root route</h1>'


@sensor_view.route('/latest', methods=['GET'])
def get_latest():
    all_data = Sensor.query.order_by(Sensor.id.desc()).all()
    data_list = []
    for entry in all_data:
        data_dict = {
            'id': entry.id,
            'address': entry.address,
            'type': entry.type,
            'value': entry.value,
            'date': entry.date
        }
        data_list.append(data_dict)
    return jsonify(data_list)

@sensor_view.route('/latest/<int:number>', methods=['GET'])
def get_latest_number_entries(number):
    all_data = Sensor.query.order_by(Sensor.id.desc()).limit(number).all()
    data_list = []
    for entry in all_data:
        data_dict = {
            'id': entry.id,
            'address': entry.address,
            'type': entry.type,
            'value': entry.value,
            'date': entry.date
        }
        data_list.append(data_dict)
    return jsonify(data_list)

@sensor_view.route('/<string:sensor_type>/latest/<int:number>', methods=['GET'])
def get_latest_entries_by_type(sensor_type, number):
    all_data = Sensor.query.filter_by(type=sensor_type).order_by(Sensor.id.desc()).limit(number).all()
    data_list = []
    for entry in all_data:
        data_dict = {
            'id': entry.id,
            'address': entry.address,
            'type': entry.type,
            'value': entry.value,
            'date': entry.date
        }
        data_list.append(data_dict)
    return jsonify(data_list)

@sensor_view.route('/<string:sensor_type>/latest', methods=['GET'])
def get_latest_entries_by_type(sensor_type, number):
    all_data = Sensor.query.filter_by(type=sensor_type).order_by(Sensor.id.desc()).all()
    data_list = []
    for entry in all_data:
        data_dict = {
            'id': entry.id,
            'address': entry.address,
            'type': entry.type,
            'value': entry.value,
            'date': entry.date
        }
        data_list.append(data_dict)
    return jsonify(data_list)

@security_view.route('/login', methods=['POST'])
def login():
    # getting the username and password from the POST body
    username = request.json.get("username",  None)
    password = request.json.get('password', None)


    # getting the user with the username username
    user_database = User.query.filter_by(username=username).all()

    # checking if there are any users with this username
    if len(user_database) == 1:
        if user_database[0].password == password:
            # create a valid JWT for the client
            payload = {
                'iat' : datetime.utcnow(),
                'exp' : datetime.utcnow() + timedelta(days=365)
            }

            # encrypting the payload
            token = jwt.encode(
                payload,
                app.config.get('JWT_SECRET_KEY'),
                algorithm='HS256'
            )

            # return the token
            return jsonify({'JWT':token})
        
        # invalid credentials
        return jsonify({'error':'Invalid username or password!'}), 401

    # no user with the given username
    return jsonify({'error':'Invalid username or password!'}), 401