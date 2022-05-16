from uuid import UUID
from flask import (Flask, render_template, make_response, url_for, request,
                   redirect, flash, session, send_from_directory, jsonify)
from werkzeug.utils import secure_filename
import bcrypt
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
    return render_template('main_not_logged_in.html')

@app.route('/join/', methods=["GET", "POST"])
def join():
    if request.method == 'GET':
        return render_template('create_user.html')
    else:
        username = request.form.get('username')
        passwd1 = request.form.get('password1')
        passwd2 = request.form.get('password2')
        about = request.form.get('about')
        genres = request.form.getlist('genre')
        f = request.files['pic']
        user_filename = f.filename
        ext = user_filename.split('.')[-1]
        fav_genres = ""
        for genre in genres:
            fav_genres = fav_genres + "," + genre
        if passwd1 != passwd2:
            flash('passwords do not match')
            return redirect( url_for('index'))
        hashed = bcrypt.hashpw(passwd1.encode('utf-8'),
                            bcrypt.gensalt())
        stored = hashed.decode('utf-8')
        try:
            conn = dbi.connect()
            curs = dbi.dict_cursor(conn)
            curs.execute('''INSERT INTO user(`uid`,uname,hashed,bio,fav_genres)
                            VALUES(null,%s,%s,%s,%s)''',
                        [username, stored, about, fav_genres])
            conn.commit()
            curs.execute('select last_insert_id()')
            row = curs.fetchone()
            print("row is", row)
            uid = row['last_insert_id()']
            filename = secure_filename('{}.{}'.format(uid,ext))
            pathname = os.path.join(app.config['UPLOADS'],filename)
            f.save(pathname)
            curs.execute('''INSERT INTO picfile(`uid`,filename) 
                        VALUES (%s,%s)
                        ON DUPLICATE KEY UPDATE filename = %s''',
                        [uid, filename, filename])
            conn.commit()
        except Exception as err:
            flash('There was an error: {}'.format(repr(err)))
            return redirect(url_for('index'))
        flash('FYI, you were issued UID {}'.format(uid))
        session['username'] = username
        session['uid'] = uid
        session['logged_in'] = True
        numrows = curs.execute('''select filename from picfile where `uid` = %s''',
                            [uid])
        row = curs.fetchone()
        return redirect( url_for('user_profile', uid=uid) )

@app.route('/login/', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')
    else:
        username = request.form.get('username')
        passwd = request.form.get('password')
        conn = dbi.connect()
        curs = dbi.dict_cursor(conn)
        curs.execute('''SELECT `uid`,hashed
                        FROM user
                        WHERE uname = %s''',
                    [username])
        row = curs.fetchone()
        if row is None:
            # Same response as wrong password,
            # so no information about what went wrong
            flash('login incorrect. Try again or join')
            return redirect( url_for('index'))
        stored = row['hashed']
        print('database has stored: {} {}'.format(stored,type(stored)))
        print('form supplied passwd: {} {}'.format(passwd,type(passwd)))
        hashed2 = bcrypt.hashpw(passwd.encode('utf-8'),
                                stored.encode('utf-8'))
        hashed2_str = hashed2.decode('utf-8')
        print('rehash is: {} {}'.format(hashed2_str,type(hashed2_str)))
        if hashed2_str == stored:
            print('they match!')
            flash('successfully logged in as '+username)
            session['username'] = username
            session['uid'] = row['uid']
            session['logged_in'] = True
            session['visits'] = 1
            return redirect( url_for('user_profile', uid=session['uid']) )
        else:
            flash('login incorrect. Try again or join')
            return redirect( url_for('index'))

@app.route('/logout/')
def logout():
    if 'username' in session:
        username = session['username']
        session.pop('username')
        session.pop('uid')
        session.pop('logged_in')
        flash('You are logged out')
        return redirect(url_for('index'))
    else:
        flash('you are not logged in. Please login or join')
        return redirect( url_for('index') )

@app.route('/query/')
def submission_handler():
    conn = dbi.connect()
    query = request.args['query']
    kind = request.args['kind']
    if kind == 'author':
        # Gets list of every author that matches the query
        authors = functions.get_author_list(conn, query)
        # If there is no match, inform the user
        if len(authors) == 0:
            return render_template('notfound.html', item = 'author', type = 'name', frag = query)
        # If there is one match, redirect to the appropriate page
        elif len(authors) == 1:
            return redirect(url_for('show_author', aid = authors[0]['aid']))
        # If there are multiple matches, list hyperlinks to various author pages
        elif len(authors) > 1:
            return render_template('many_authors_found.html', frag = query, group = authors)

    elif kind == 'book':
        # Gets list of every book that matches the query
        books = functions.get_book_list(conn, query)
        # If there is no match, inform the user
        if len(books) == 0:
            return render_template('notfound.html', item = 'book', type = 'title', frag = query)
        # If there is one match, redirect to the appropriate page
        elif len(books) == 1:
            return redirect(url_for('show_book', bid = books[0]['bid']))
        # If there are multiple matches, list hyperlinks to various book pages
        elif len(books) > 1:
            return render_template('many_books_found.html', frag = query, group = books)
    
    elif kind == 'user':
        # Gets list of every user that matches the query
        users = functions.get_user_list(conn, query)
        # If there is no match, inform the user
        if len(users) == 0:
            return render_template('notfound.html', item = 'user', type = 'name', frag = query)
        # If there is one match, redirect to the appropriate page
        elif len(users) == 1:
            return redirect(url_for('user_profile', uid = users[0]['uid']))
        # If there are multiple matches, list hyperlinks to various user pages
        elif len(users) > 1:
            return render_template('many_users_found.html', frag = query, group = users)

@app.route('/user/<uid>', methods=['GET'])
def user_profile(uid):
    conn = dbi.connect()
    curs = dbi.dict_cursor(conn)
    user_info = functions.get_user_info(conn, uid) 
    uname = user_info.get('uname')
    bio = user_info.get('bio')
    fav_genres = user_info.get('fav_genres')
    friends = functions.get_friends(conn, uid)
    shelves = functions.get_shelves(conn, uid)
    uid = int(uid) # cast to int since uid is initially coming from the url and is a string
    return render_template('user_profile.html', uid = uid, name = uname, bio = bio, 
                            genres = fav_genres, friends = friends,
                            shelves = shelves, session = session)

@app.route('/pic/<uid>')
def pic(uid):
    conn = dbi.connect()
    curs = dbi.dict_cursor(conn)
    numrows = curs.execute(
        '''select filename from picfile where `uid` = %s''',
        [uid])
    if numrows == 0:
        flash('No picture for {}'.format(uid))
        return send_from_directory(app.config['UPLOADS'],'default.jpg')
    row = curs.fetchone()
    return send_from_directory(app.config['UPLOADS'],row['filename'])

@app.route('/edit/', methods=["GET", "POST"])
def edit():
 
   if request.method == 'GET':
 
       return render_template('edit.html')
 
   else:
 
       about = request.form.get('about')
       romance = request.form.get('romance')
       mystery = request.form.get('mystery')
       scifi = request.form.get('science-fiction')
       nonfiction = request.form.get('nonfiction')
       fiction = request.form.get('fiction')
       horror = request.form.get('horror')
       fav_genres = ""
 
       for genre in [romance, mystery, scifi, nonfiction, fiction, horror]:
               if genre:
                   fav_genres = fav_genres + "," + genre
       uid = session['uid']
       conn = dbi.connect()
       curs = dbi.dict_cursor(conn)
 
       curs.execute('''update user
                   set bio = %s, fav_genres = %s
                   where uid = %s''', [about, fav_genres, uid])
 
       conn.commit()
 
       return redirect( url_for('user_profile', uid=uid) )

@app.route('/shelf/<shelf_id>', methods=['GET'])
def display_shelf(shelf_id):
    conn = dbi.connect()
    books = functions.get_shelf_books(conn, shelf_id)
    if len(books) != 0:
        shelf_name = books[0].get('shelf_name')
        return render_template('bookshelf.html', books = books, shelf_name = shelf_name)    
    else:
        curs = dbi.dict_cursor(conn)
        curs.execute('''select shelf_name from shelf where shelf_id = %s''', [shelf_id])
        shelf_name = curs.fetchone().get('shelf_name')
        return render_template('empty_bookshelf.html', shelf_name = shelf_name)


@app.route('/all-books', methods=['GET'])
def all_books():
    conn = dbi.connect()
    books = functions.get_all_books(conn)
    bid = books[0]
    return render_template('all_books.html',bid=bid,books=books)


@app.route('/book/<bid>', methods=['GET'])
def show_book(bid):
    conn = dbi.connect()
    book_info = functions.get_book(conn, bid)
    title = book_info.get('bname')
    author = book_info.get('author')
    author_id = book_info.get('aid')
    genre = book_info.get('genre')
    avg_rating = book_info.get('avg_rating')
    all_reviews = functions.get_reviews(conn, bid)
    username = session['username']
    sesh_uid = functions.get_user_id(conn, username)
    sesh_user_has_posted = False
    sesh_user_review = None
    for review in all_reviews:
        if review.get('uname') == username:
            sesh_user_has_posted = True
            sesh_user_review = review
    shelves = functions.get_shelves(conn, sesh_uid)
    return render_template('book.html', title = title, bid = bid,
                            genre = genre, avg_rating = avg_rating,
                            author = author, aid = author_id, 
                            sesh_user_has_posted = sesh_user_has_posted,
                            all_reviews = all_reviews, shelves = shelves,
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
    conn = dbi.connect()
    review = functions.get_review(conn, review_id)
    book = review.get('bname')
    uname = review.get('uname')
    date = review.get('post_date')
    content = review.get('content')
    rating = review.get('rating')
    all_replies = functions.get_replies(conn, review_id)
    username = session['username']
    sesh_uid = functions.get_user_id(conn, username)
    sesh_user_has_replied = False
    sesh_user_reply = None
    for reply in all_replies:
        if reply.get('uname') == username:
            sesh_user_has_replied = True
            sesh_user_reply = reply
    return render_template('review.html', book=book, uname=uname, date=date,
                            review_id=review_id,content=content,rating=rating,
                            all_replies=all_replies,
                            sesh_user_has_replied=sesh_user_has_replied,
                            sesh_user_reply=sesh_user_reply,
                            sesh_uid=sesh_uid, sesh_user=username
                            )

@app.route('/reply/<review_id>/<uid>', methods=['GET', 'POST'])
def post_reply(review_id,uid):
    if request.method == 'GET':
        conn = dbi.connect()
        review_info = functions.get_review(conn, review_id)
        review_id = review_info.get('review_id')
        return render_template('post_reply.html', review_id=review_id,uid=uid)
    else:
        conn = dbi.connect()
        functions.post_reply(conn, uid, review_id, request.form['content'])
        flash('replied!')
        return redirect(url_for('show_review', review_id=review_id))

@app.route('/author/<aid>', methods=['GET'])
def show_author(aid):
    conn = dbi.connect()
    author_info = functions.get_author(conn, aid)
    name = author_info.get('author')
    bio = author_info.get('author_bio')
    books = functions.get_author_books(conn, aid)
    return render_template('author.html', name = name,
                            bio = bio, books = books)

@app.route('/shelf/<bid>', methods = ['POST'])
def add_to_shelf(bid):
    conn = dbi.connect()
    username = session['username']
    sesh_uid = functions.get_user_id(conn, username)
    shelf_name = request.form['shelf_name']
    if shelf_name == 'Want':
        shelf_name = 'Want to read'
    check = functions.is_book_on_shelf(conn, 'Want to read', bid, sesh_uid)
    check2 = functions.is_book_on_shelf(conn, 'Read', bid, sesh_uid)
    #if shelf_name is read and book is on want to read, delete from want to read
    if (shelf_name == 'Read') and (check != None):
        functions.delete_book(conn, 'Want to read', bid, sesh_uid)
        functions.add_to_shelf(conn, shelf_name, bid, sesh_uid)
        flash('Added to your ' + str(shelf_name) + ' bookshelf')
    #if shelf_name is want to read and book is on read, do nothing (do not add to want to read)
    elif (shelf_name == 'Want to read') and (check2 != None):
        flash('You already read this book!')
    else:
        functions.add_to_shelf(conn, shelf_name, bid, sesh_uid)
        flash('Added to your ' + str(shelf_name) + ' bookshelf')
    return redirect(url_for('show_book', bid = bid))

@app.route('/shelf/', methods = ['POST'])
def new_shelf():
    conn = dbi.connect()
    username = session['username']
    sesh_uid = functions.get_user_id(conn, username)
    shelf_name = request.form['shelf']
    functions.add_shelf(conn, sesh_uid, shelf_name)
    return redirect(url_for('user_profile', uid = sesh_uid))

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
