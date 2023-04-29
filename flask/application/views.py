from flask import Blueprint, jsonify

from .models import Sensor

# creating a blueprint
sensor_view = Blueprint('sensor_view', __name__)

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

@sensor_view.route('/types', methods=['GET'])
def get_sensor_types():
    all_data = Sensor.query.get(type).distinct().all()
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
