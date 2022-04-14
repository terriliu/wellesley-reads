from flask import (Flask, render_template, make_response, url_for, request,
                   redirect, flash, session, send_from_directory, jsonify)
from werkzeug.utils import secure_filename
import functions # helper functions
app = Flask(__name__)

# one or the other of these. Defaults to MySQL (PyMySQL)
# change comment characters to switch to SQLite

import cs304dbi as dbi
# import cs304dbi_sqlite3 as dbi

import random

app.secret_key = 'your secret here'
# replace that with a random key
app.secret_key = ''.join([ random.choice(('ABCDEFGHIJKLMNOPQRSTUVXYZ' +
                                          'abcdefghijklmnopqrstuvxyz' +
                                          '0123456789'))
                           for i in range(20) ])

# This gets us better error messages for certain common request errors
app.config['TRAP_BAD_REQUEST_ERRORS'] = True

@app.route('/')
def index():
    return render_template('main.html',title='Hello')

@app.route('/user/<uid>', methods=['GET'])
def user_profile(uid):
    conn1 = dbi.connect()
    user_info = functions.get_user_info(conn1, uid) # example of calling helper functions
    uname = user_info.get('uname')
    bio = user_info.get('bio')
    fav_genres = user_info.get('fav_genres')
    conn2 = dbi.connect()
    friends = functions.get_friends(conn2, uid)
    conn3 = dbi.connect()
    shelves = functions.get_shelves(conn3, uid)
    return render_template('user_profile.html', name = uname, bio = bio, 
                            genres = fav_genres, friends = friends,
                            shelves = shelves)

@app.route('/shelf/<shelf_id>', methods=['GET'])
def display_shelf(shelf_id):
    conn = dbi.connect()
    books = functions.get_shelf_books(conn, shelf_id)
    shelf_name = books[0].get('shelf_name')
    return render_template('bookshelf.html', books = books, shelf_name = shelf_name)    

@app.route('/book/<bid>', methods=['GET'])
def show_book(bid):
    conn = dbi.connect()
    book_info = functions.get_book(conn, bid)
    title = book_info.get('bname')
    author = book_info.get('author')
    author_id = book_info.get('aid')
    genre = book_info.get('genre')
    avg_rating = book_info.get('avg_rating')
    return render_template('book.html', title = title,
                            genre = genre, avg_rating = avg_rating,
                            author = author, aid = author_id)

@app.route('/author/<aid>', methods=['GET'])
def show_author(aid):
    conn = dbi.connect()
    author_info = functions.get_author(conn, aid)
    name = author_info.get('author')
    bio = author_info.get('author_bio')
    books = functions.get_author_books(conn, aid)
    return render_template('author.html', name = name,
                            bio = bio, books = books)

# Below routes are from the flask starter
@app.route('/greet/', methods=["GET", "POST"])
def greet():
    if request.method == 'GET':
        return render_template('greet.html', title='Customized Greeting')
    else:
        try:
            username = request.form['username'] # throws error if there's trouble
            flash('form submission successful')
            return render_template('greet.html',
                                   title='Welcome '+username,
                                   name=username)

        except Exception as err:
            flash('form submission error'+str(err))
            return redirect( url_for('index') )

@app.route('/formecho/', methods=['GET','POST'])
def formecho():
    if request.method == 'GET':
        return render_template('form_data.html',
                               method=request.method,
                               form_data=request.args)
    elif request.method == 'POST':
        return render_template('form_data.html',
                               method=request.method,
                               form_data=request.form)
    else:
        # maybe PUT?
        return render_template('form_data.html',
                               method=request.method,
                               form_data={})

@app.route('/testform/')
def testform():
    # these forms go to the formecho route
    return render_template('testform.html')


@app.before_first_request
def init_db():
    dbi.cache_cnf()
    db_to_use = 'wellesleyreads_db' 
    dbi.use(db_to_use)
    print('will connect to {}'.format(db_to_use))

if __name__ == '__main__':
    import sys, os
    if len(sys.argv) > 1:
        # arg, if any, is the desired port number
        port = int(sys.argv[1])
        assert(port>1024)
    else:
        port = os.getuid()
    app.debug = True
    app.run('0.0.0.0',port)
