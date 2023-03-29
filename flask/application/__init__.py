from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from os import path
import struct
from threading import Thread
from pyrf24 import RF24, RF24Network, RF24NetworkHeader

from .update_db import update_database

# creating the database
db = SQLAlchemy()

# setting the db name
DB_NAME = 'database.db'

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

# create the thread to update the database
update_db_thread = Thread(target=update_database, args=(db,))


def create_app():
    # create the flask app
    app = Flask(__name__)

    # set the encryption key
    app.config['SECRET_KEY'] = 'first version'

    # let flask know of the database location (local db)
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{DB_NAME}'

    # initialize db with the flask app
    db.init_app(app)

    # register the blueprints to our app
    from .views import views
    app.register_blueprint(views, url_prefix='/sensors')

    # make sure that we define the models
    # before it creates the db
    from .models import Sensor
    create_db(app)

    # constantly update the database with new values
    update_db_thread.start()

    # return the flask app
    return app

def create_db(app):
    if not path.exists('application/' + DB_NAME):
        db.create_all(app=app)
        print('Created database!')