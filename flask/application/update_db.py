import struct

from .models import Sensor

def update_database(db, network, radio, EXPECTED_SIZE):
    try:
        while True:
            network.update()
            while network.available():
                header, payload = network.read()
                sensor_type, value = struct.unpack("<BL", payload[:EXPECTED_SIZE])
                sensor_type = chr(sensor_type)
                address = header.to_string().split(' ')[3]
                print(f'payload len: {len(payload)}, sensor type: {sensor_type}, value: {value}, header: {header.to_string()}')

                # creating a db entry
                sensor_db_entry = Sensor(address=address, type=sensor_type, value=value)

                # add to database
                db.session.add(sensor_db_entry)

                # commit the changes to the db
                db.session.commit()
    except KeyboardInterrupt:
        print("powering down radio and exiting.")
        radio.power = False