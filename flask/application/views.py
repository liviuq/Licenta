from flask import Blueprint, jsonify

from .models import Sensor

# creating a blueprint
views = Blueprint('views', __name__)

@views.route('/latest', methods=['GET'])
def get_latest():
    all_data = Sensor.query.all()
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

@views.route('/latest/10')
def latest_10():
    return '<p>Latest values 10</p>'