# Helper functions (e.g., sql statements)
from curses import KEY_SFIND
from flask import (Flask, render_template, make_response, url_for, request,
redirect, flash, session, send_from_directory, jsonify)
from werkzeug.utils import secure_filename

app = Flask(__name__)

import cs304dbi as dbi


def get_user_info(conn, uid):
    curs = dbi.dict_cursor(conn)
    curs.execute('''select * from user where `uid` = %s''', uid)
    return curs.fetchone() 

def get_friends(conn, uid):
    curs = dbi.dict_cursor(conn)
    curs.execute('''select userB.`uid`, userB.uname from user as userA
                    inner join befriend on (userA.`uid` = befriend.uid_1) 
                    inner join user as userB on (userB.`uid` = befriend.uid_2)
                    where userA.`uid` = %s''', uid) 
    return curs.fetchall()

def get_shelves(conn, uid):
    curs = dbi.dict_cursor(conn)
    curs.execute('''select shelf_id, shelf_name from shelf
                    inner join user using (`uid`)
                    where `uid`=%s''', uid)
    return curs.fetchall()

def get_shelf_books(conn, shelf_id):
    curs = dbi.dict_cursor(conn)
    curs.execute('''select bid, bname, shelf_name from book
                    inner join book_on_shelf using (bid)
                    inner join shelf using (shelf_id)
                    where shelf_id=%s''', shelf_id)
    return curs.fetchall()

def get_book(conn, bid):
    curs = dbi.dict_cursor(conn)
    curs.execute('''select book.bid, book.bname, book.genre, 
                    book.avg_rating, author.aid, author.author from book 
                    inner join author using (aid) 
                    where book.bid = %s''', bid)
    return curs.fetchone()

def get_author(conn, aid):
    curs = dbi.dict_cursor(conn)
    curs.execute('''select * from author where aid=%s''', aid)
    return curs.fetchone()

def get_author_books(conn, aid):
    curs = dbi.dict_cursor(conn)
    curs.execute('''select bid, bname from book
                    inner join author using (aid)
                    where aid=%s''', aid)
    return curs.fetchall()
    
if __name__ == '__main__':
    dbi.cache_cnf()
    dbi.use('wellesleyreads_db')

    import os
    port = os.getuid()
    app.debug = True
    app.run('0.0.0.0',port)