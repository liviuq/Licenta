import json
import requests
from datetime import datetime
from . import app_reference, db_reference

from sqlalchemy.sql import func 
from flask import Blueprint, jsonify, request

from .models import Sensor, AdvancedSensor
# creating the blueprints
sensor_view = Blueprint('sensor_view', __name__)
advanced_view = Blueprint('advanced_view', __name__)

@advanced_view.route('/', methods=['GET','PUT', 'DELETE'])
def advanced_sensor_root():
    global app_reference, db_reference

    # check if the request is a GET request
    if request.method == 'GET':
        all_data = AdvancedSensor.query.all()
        data_list = []
        for entry in all_data:
            data_dict = {
                'ip': entry.ip,
                'name': entry.name,
                'endpoints': entry.endpoints,
                'date': entry.date
            }
            data_list.append(data_dict)
        return jsonify(data_list)
    
    elif request.method == 'PUT':

        # force the request to be json
        sensor_data = request.get_json(force=True)
        
        # checking if the same ip address is found in the table AdvancedSensor
        sensor_db = AdvancedSensor.query.get(sensor_data['ip'])
        
        # if there are no sensors with the same ip address
        if sensor_db is None:

            # add to database
            with app_reference.app_context():

                parsed_endpoint = json.dumps(sensor_data['endpoints'].__str__())
                # create an AdvancedSensor object
                sensor_db_entry = AdvancedSensor(ip=sensor_data['ip'], name=sensor_data['name'], endpoints=parsed_endpoint)
                db_reference.session.add(sensor_db_entry)
                db_reference.session.commit()
            return sensor_data, 201 # created new resource

        # if there is a sensor with the same ip address
        else:
            with app_reference.app_context():

                parsed_endpoint = json.dumps(sensor_data['endpoints'].__str__())
                #  update it's fields
                sensor_db.name = sensor_data['name']
                sensor_db.endpoints = parsed_endpoint
                sensor_db.date = func.now()
                db_reference.session.commit()
            return 'updated sensor', 200 # updated resource
        
    elif request.method == 'DELETE':

        # force the request to be json
        sensor_data = request.get_json(force=True)

        # retrieve the IP address from the request parameters or JSON payload
        ip_address = sensor_data['ip']

        # checking if the sensor exists
        sensor_db = AdvancedSensor.query.get(ip_address)
        if sensor_db is None:
            return 'Sensor not found', 404  # not Found

        # Delete the sensor from the database
        with app_reference.app_context():
            db_reference.session.delete(sensor_db)
            db_reference.session.commit()
        return 'Sensor deleted', 200  # Success
    
@advanced_view.route('/request', methods=['GET'])
def advanced_sensor_request():

    # retrieve the IP address and endpoint from the request parameters
    sensor_ip = request.args.get('ip')
    sensor_endpoint = request.args.get('endpoint')

    # make a GET request to sensor_ip/sensor_endpoint
    try:
        response = requests.get(f"http://{sensor_ip}/{sensor_endpoint}")
    except requests.exceptions.RequestException as e:
        return f'GET request received with IP: {sensor_ip} and endpoint: {sensor_endpoint}. Error: {e}', 500

    # Process the response as needed
    response_content = response.text
    response_code = response.status_code
    
    return f'GET request received with IP: {sensor_ip} and endpoint: {sensor_endpoint}. Response Code: {response_code}. Response Content: {response_content}', response_code

@sensor_view.route('/', methods=['GET'])
def lulz():
    return '<p>hi</p>'

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

@sensor_view.route('/<string:sensor_type>/<string:sensor_address>/latest/<int:number>', methods=['GET'])
def get_latest_entries_specific_sensor(sensor_address, sensor_type, number):
    all_data = Sensor.query.filter_by(address=sensor_address, type=sensor_type).order_by(Sensor.id.desc()).limit(number).all()
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

@sensor_view.route('/<string:sensor_type>/addresses', methods=['GET'])
def get_sensor_addresses_by_type(sensor_type):
    all_data = Sensor.query.filter_by(type=sensor_type).with_entities(Sensor.address).distinct().all()
    data_list = []
    for entry in all_data:
        data_list.append(entry.address)
    return jsonify({"addresses":data_list})

@sensor_view.route('/types', methods=['GET'])
def get_sensor_types():
    all_data = Sensor.query.with_entities(Sensor.type).distinct().all()
    data_list = []
    for entry in all_data:
        data_list.append(entry.type)
    return jsonify({"types":data_list})

@sensor_view.route('/sensors', methods=['GET'])
def sensors():
    all_static = Sensor.query.group_by(Sensor.address).having(func.max(Sensor.id)).order_by(Sensor.id).all()
    list_static = []

    all_advanced = AdvancedSensor.query.all()
    list_advanced = []

    for entry in all_static:
        data_dict = {
            'id': entry.id,
            'address': entry.address,
            'type': entry.type,
            'value': entry.value,
            'date': entry.date
        }
        list_static.append(data_dict)

    for entry in all_advanced:
        data_dict = {
             'ip': entry.ip,
             'name': entry.name,
             'endpoints': entry.endpoints,
             'date': entry.date
        }
        list_advanced.append(data_dict)

    return jsonify({'static':list_static, 'advanced':list_advanced})

@sensor_view.route('/secure', methods=['GET', 'POST'])
def secure():
    if request.method == 'POST':
        value = request.args.get('value')
        if value is not None:
            with open('secure_value', 'w') as file:
                file.write(value)
            return jsonify({'value':value})
        else:
            return jsonify({'value':'Error at setting the value'})
    elif request.method == 'GET':
        with open('secure_value', 'r') as file:
            value = file.read()
        return jsonify({'value':value})

@sensor_view.route('/report', methods=['POST'])
def get_report_information():

    request_data = request.get_json()
    start_date_str = request_data.get('start_date')
    end_date_str = request_data.get('end_date')

    # Convert the date strings to datetime objects
    date_format = "%a, %d %b %Y %H:%M:%S %Z"
    start_date = datetime.strptime(start_date_str, date_format)
    end_date = datetime.strptime(end_date_str, date_format)

    # Query the Sensor table for rows between the specified dates
    query = Sensor.query.filter(Sensor.date.between(start_date, end_date)).order_by(Sensor.id.desc()).all()

    data_list = []
    for entry in query:
        data_dict = {
            'id': entry.id,
            'address': entry.address,
            'type': entry.type,
            'value': entry.value,
            'date': entry.date
        }
        data_list.append(data_dict)

    return jsonify(data_list)
