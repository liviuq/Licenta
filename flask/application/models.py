from sqlalchemy.sql import func # gets current datetime

from . import db


class Sensor(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    address = db.Column(db.String(8))
    type = db.Column(db.String(1))
    value = db.Column(db.Integer)
    date = db.Column(db.DateTime(timezone=True), default=func.now())


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(128), nullable=False)
    password = db.Column(db.String(128), nullable=False)
    date = db.Column(db.DateTime(timezone=True), default=func.now())
