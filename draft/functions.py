# Helper functions (e.g., sql statements)
from curses import KEY_SFIND
from flask import (Flask, render_template, make_response, url_for, request,
redirect, flash, session, send_from_directory, jsonify)
from werkzeug.utils import secure_filename

app = Flask(__name__)

import cs304dbi as dbi


# An example
def get_user_info(conn, uid):
    curs = dbi.dict_cursor(conn)
    curs.execute('''select uname from user where `uid` = %s''', uid)
    return curs.fetchone() 

if __name__ == '__main__':
    dbi.cache_cnf()
    dbi.use('wellesleyreads_db')

    import os
    port = os.getuid()
    app.debug = True
    app.run('0.0.0.0',port)