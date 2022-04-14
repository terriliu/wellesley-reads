from uuid import UUID
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
    if 'username' in session:
        username = session['username']
        conn = dbi.connect()
        uid = functions.get_user_id(conn, username)
        return redirect(url_for('user_profile', uid=uid))
        #return render_template('main.html',title='Hello', username=username)
    return render_template('main_not_logged_in.html')

@app.route('/login', methods = ['GET', 'POST'])
def login():
   if request.method == 'POST':
      session['username'] = request.form['username']
      return redirect(url_for('index'))
   return render_template('login.html')

@app.route('/logout')
def logout():
   # remove the username from the session if it is there
   session.pop('username', None)
   return redirect(url_for('index'))

@app.route('/user/<uid>', methods=['GET'])
def user_profile(uid):
    conn1 = dbi.connect()
    user_info = functions.get_user_info(conn1, uid) 
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
    conn1 = dbi.connect()
    book_info = functions.get_book(conn1, bid)
    title = book_info.get('bname')
    author = book_info.get('author')
    author_id = book_info.get('aid')
    genre = book_info.get('genre')
    avg_rating = book_info.get('avg_rating')
    conn2 = dbi.connect()
    all_reviews = functions.get_reviews(conn2, bid)
    username = session['username']
    conn3 = dbi.connect()
    sesh_uid = functions.get_user_id(conn3, username)
    sesh_user_has_posted = False
    sesh_user_review = None
    for review in all_reviews:
        if review.get('uname') == username:
            sesh_user_has_posted = True
            sesh_user_review = review
    return render_template('book.html', title = title, bid = bid,
                            genre = genre, avg_rating = avg_rating,
                            author = author, aid = author_id, 
                            sesh_user_has_posted = sesh_user_has_posted,
                            all_reviews = all_reviews, 
                            sesh_user_review = sesh_user_review, 
                            sesh_uid = sesh_uid, sesh_user = username)

@app.route('/review/<bid>/<uid>', methods=['GET', 'POST'])
def post_review(bid, uid):
    if request.method == 'GET':
        conn = dbi.connect()
        book_info = functions.get_book(conn, bid)
        bname = book_info.get('bname')
        return render_template('post_review.html', bname=bname)
    else:
        conn = dbi.connect()
        functions.post_review(conn, bid, uid, request.form['rating'], request.form['content'])
        flash('review posted!')
        return redirect( url_for('show_book', bid=bid) )

@app.route('/review/<review_id>', methods=['GET'])
def show_review(review_id):
    conn1 = dbi.connect()
    review = functions.get_review(conn1, review_id)
    book = review.get('bname')
    uname = review.get('uname')
    date = review.get('post_date')
    content = review.get('content')
    rating = review.get('rating')
    conn2 = dbi.connect()
    replies = functions.get_replies(conn2, review_id)
    return render_template('review.html', book=book, uname=uname, date=date,
                            content=content,rating=rating,replies=replies)

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
