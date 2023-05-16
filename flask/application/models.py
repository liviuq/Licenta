from sqlalchemy.sql import func # gets current datetime

from . import db


class Sensor(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    address = db.Column(db.String(8))
    type = db.Column(db.String(16))
    value = db.Column(db.Integer)
    date = db.Column(db.DateTime(timezone=True), default=func.now())

class AdvancedSensor(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    ip = db.Column(db.String(16))
    name = db.Column(db.String(64))
    endpoints = db.Column(db.String(512))
    date = db.Column(db.DateTime(timezone=True), default=func.now())
