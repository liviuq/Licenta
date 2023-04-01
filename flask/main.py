from threading import Thread

from application import create_app
from application.update_db import update_database

# creating the flask app which returns the app object and db instance
app, db = create_app()

# run the app only if called from app.py
if __name__ == '__main__':
    # spin up a thread to constantly populate the database with new sensor data
    update_db = Thread(target=update_database, args=(app, db,))
    update_db.start()

    # run flask app
    app.run(debug=True, host='0.0.0.0')

