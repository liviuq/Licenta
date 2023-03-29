from flask import Blueprint

# creating a blueprint
views = Blueprint('views', __name__)

@views.route('/latest')
def latest():
    return '<p>Latest values</p>'