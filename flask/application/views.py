from . import app_reference, db_reference

from sqlalchemy.sql import func 
from flask import Blueprint, jsonify, request

from .models import Sensor, AdvancedSensor
# creating the blueprints
sensor_view = Blueprint('sensor_view', __name__)
advanced_view = Blueprint('advanced_view', __name__)

@advanced_view.route('/', methods=['GET','PUT'])
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
    
    if request.method == 'PUT':

        # force the request to be json
        sensor_data = request.get_json(force=True)
        
        # checking if the same ip address is found in the table AdvancedSensor
        sensor_db = AdvancedSensor.query.get(sensor_data['ip'])
        
        # if there are no sensors with the same ip address
        if sensor_db is None:

            # add to database
            with app_reference.app_context():

                # create an AdvancedSensor object
                sensor_db_entry = AdvancedSensor(ip=sensor_data['ip'], name=sensor_data['name'], endpoints=sensor_data['endpoints'])
                db_reference.session.add(sensor_db_entry)
                db_reference.session.commit()
            return sensor_data, 201 # created new resource

        # if there is a sensor with the same ip address
        else:
            with app_reference.app_context():

                #  update it's fields
                sensor_db.name = sensor_data['name']
                sensor_db.endpoints = sensor_data['endpoints']
                sensor_db.date = func.now()
                db_reference.session.commit()
            return 'updated sensor', 200 # updated resource

# @advanced_view.route('/get', methods=['GET'])
# def get_advanced_sensors():
#     all_data = AdvancedSensor.query.all()
#     data_list = []
#     for entry in all_data:
#         data_dict = {
#             'ip': entry.ip,
#             'name': entry.name,
#             'endpoints': entry.endpoints,
#             'date': entry.date
#         }
#         data_list.append(data_dict)
#     return jsonify(data_list)

# just  for the lulz
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
    all_data = Sensor.query.group_by(Sensor.address).having(func.max(Sensor.id)).order_by(Sensor.id).all()
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
