-- check if you are using the correct database
use wellesleyreads_db; 

<<<<<<< HEAD
--user table
load data local infile 'user.csv' 
into table user 
fields terminated by ',' 
enclosed by '"' lines 
=======
-- user table
load data local infile 'user.csv' 
into table user 
fields terminated by ',' 
enclosed by "" lines 
>>>>>>> 3023ebd1f9f75db7b530a52f91f099d514b8ef82
terminated by '\r\n' 
ignore 1 rows 
(uname,bio,fav_genres);

<<<<<<< HEAD
--befriend table
load data local infile 'befriend.csv'
into table befriend
fields terminated by ',' 
enclosed by '"' lines 
=======
-- befriend table
load data local infile 'befriend.csv' 
into table befriend 
fields terminated by ',' 
enclosed by "" lines 
>>>>>>> 3023ebd1f9f75db7b530a52f91f099d514b8ef82
terminated by '\r\n' 
ignore 1 rows 
(uid_1,uid_2);

--author table
load data local infile 'author.csv' 
into table author 
fields terminated by ',' 
enclosed by '"' lines 
terminated by '\r\n' 
ignore 1 rows 
(aid,author,author_bio,has_user_account,user_account_id);

-- book table
load data local infile 'book.csv' 
into table book 
fields terminated by ',' 
enclosed by '"' 
lines terminated by '\r\n' 
ignore 1 rows 
(bid,bname,genre,avg_rating,aid);

-- shelf table
load data local infile 'shelf.csv' 
into table shelf 
fields terminated by ',' 
enclosed by '"' lines 
terminated by '\r\n' 
ignore 1 rows 
(uid,shelf_name);

--book_on_shelf table
load data local infile 'book_on_shelf.csv' 
into table book_on_shelf 
fields terminated by ',' 
enclosed by '"' lines 
terminated by '\r\n' 
ignore 1 rows 
(bid,shelf_id);

--review table TODO: not sure i got the csv file right..
load data local infile 'review.csv' 
into table review
fields terminated by ',' 
enclosed by '"' lines 
terminated by '\r\n' 
ignore 1 rows 
(uid,bid,rating,content,post_date);