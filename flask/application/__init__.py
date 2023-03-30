from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from os import path


# creating the database
db = SQLAlchemy()

# setting the db name
DB_NAME = 'database.db'


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

    # return the flask app
    return app

def create_db(app):
    if not path.exists('application/' + DB_NAME):
        db.create_all(app=app)
        print('Created database!')