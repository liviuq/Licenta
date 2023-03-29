import time

from application import create_app
from application.models import Sensor

app = create_app()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
    #time.sleep(5)
    sensor_values = Sensor.query.all()

