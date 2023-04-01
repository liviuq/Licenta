import struct
import time
from pyrf24 import RF24, RF24Network, RF24NetworkHeader

from .models import Sensor


# creating the radio object
radio = RF24(22, 0)

# creating the network on the radio object
network = RF24Network(radio)

# Address of our node in Octal format (01, 021, etc)
THIS_NODE = 0o0  # make this node behave like the network master node

# initialize the nRF24L01 on the spi bus
if not radio.begin():
    raise OSError("nRF24L01 hardware isn't responding")

radio.channel = 90
network.begin(THIS_NODE)

EXPECTED_SIZE = struct.calcsize("<BL")
def update_database(app, db):
    try:
        while True:
            network.update()
            while network.available():
                header, payload = network.read()
                sensor_type, value = struct.unpack("<BL", payload[:EXPECTED_SIZE])
                sensor_type = chr(sensor_type)
                address = header.to_string().split(' ')[3]

                # if app.config['FLASK_DEBUG']:
                #     print(f'payload len: {len(payload)}, sensor type: {sensor_type}, value: {value}, header: {header.to_string()}')

                # getting the app db context
                with app.app_context():
                    # creating a db entry
                    sensor_db_entry = Sensor(address=address, type=sensor_type, value=value)

                    # add to database
                    db.session.add(sensor_db_entry)

                    # commit the changes to the db
                    db.session.commit()
    except KeyboardInterrupt:
        print("powering down radio and exiting.")
        radio.power = False


def update_database_mock(app, db):
    try:
        while True:
            value = 0
            sensor_type = 'D'
            address = '01'
            with app.app_context():
                sensor_db_entry = Sensor(address=address, type=sensor_type, value=value)
                db.session.add(sensor_db_entry)
                db.session.commit()
            value += 1
            time.sleep(1)
    except KeyboardInterrupt:
        print("powering down radio and exiting.")