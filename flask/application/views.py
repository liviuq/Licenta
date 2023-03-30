from flask import Blueprint


# creating a blueprint
views = Blueprint('views', __name__)

@views.route('/latest')
def latest():
    return '<p>Latest values</p>'

@views.route('/latest/10')
def latest_10():
    return '<p>Latest values 10</p>'