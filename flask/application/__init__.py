from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from os import path


# creating the database
db = SQLAlchemy()

# reference to application variable
app_reference = None

# reference to database variable
db_reference = db

# setting the db name
DB_NAME = 'database.db'


def create_app():
    global app_reference

    # create the flask app
    app = Flask(__name__)

    # update the reference
    app_reference = app

    # set the encryption key
    app.config['SECRET_KEY'] = 'first version'

    # let flask know of the database location (local db)
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{DB_NAME}'

    # supress warning nad overhead usage
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # initialize db with the flask app
    db.init_app(app)

    # register the blueprints to our app
    from .views import sensor_view, advanced_view
    app.register_blueprint(sensor_view, url_prefix='/')
    app.register_blueprint(advanced_view, url_prefix='/advanced')

    # make sure that we define the models
    # before it creates the db
    from .models import Sensor, AdvancedSensor
    create_db(app)

    # return the flask app
    return app, db

def create_db(app):
    if not path.exists('application/' + DB_NAME):
        db.create_all(app=app)
        print('Created database!')
