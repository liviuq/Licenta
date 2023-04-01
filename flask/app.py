from threading import Thread

from application import create_app
from application.update_db import update_database

# creating the flask app which returns the app object and db instance
app, db = create_app()

# spin up a thread to constantly populate the database with new sensor data
update_db = Thread(target=update_database, args=(app, db,))
update_db.start()

# run flask app only from main
# as we just run it from the terminal with
# flask run --host=0.0.0.0, we just need to
# ignore a warning, as per flask documentation
if __name__ == '__main__':
    app.run()

