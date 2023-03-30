from threading import Thread

from application import create_app
from application.update_db import update_database

app, db = create_app()

if __name__ == '__main__':
    update_db = Thread(target=update_database, args=(app, db,))
    update_db.start()

    # remove the debug=True and run with
    # debug in console: --debug
    app.run(debug=True, host='0.0.0.0')

