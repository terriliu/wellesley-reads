use wellesleyreads_db;

drop table if exists reply;
drop table if exists review;
drop table if exists rate;
drop table if exists book_on_shelf;
drop table if exists shelf;
drop table if exists author;
drop table if exists book;
drop table if exists befriend;
drop table if exists user;


create table user (
    `uid` int auto_increment,
    uname varchar(10),
    bio varchar(100),
    fav_genres set('romance', 'mystery', 'science-fiction', 'nonfiction', 'fiction', 'horror'), -- TODO: add more genres
    primary key (`uid`),
    index (uname)
)
ENGINE = InnoDB;

create table befriend ( -- (personA, personB) and (personB, personA) both exists but refer to the same pairing
    uid_1 int,
    uid_2 int,
    primary key (uid_1, uid_2),
    foreign key (uid_1) references user (`uid`)
        on update cascade
        on delete restrict,
    foreign key (uid_2) references user (`uid`)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;

create table author (
    aid int auto_increment,
    author varchar(30),
    author_bio varchar(100),
    has_user_account tinyint, -- either 1 (true) or 0 (false)
    user_account_id int, -- would be NULL if has_user_account = 0
    primary key (aid),
    foreign key (user_account_id) references user (`uid`)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;

create table book (
    bid int auto_increment, -- book id
    bname varchar(40),
    genre set('romance', 'mystery', 'science-fiction', 'nonfiction', 'fiction', 'horror'),
    avg_rating float unsigned,
    aid int,
    primary key (bid),
    foreign key (aid) references author (aid)
        on update cascade
        on delete restrict,
    index (bname)
)
ENGINE = InnoDB;

create table shelf (
    shelf_id int auto_increment,
    `uid` int,
    shelf_name varchar(40),
    primary key (shelf_id),
    foreign key (`uid`) references user (`uid`)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;

create table book_on_shelf (
    bid int,
    shelf_id int,
    primary key (bid, shelf_id),
    foreign key (bid) references book (bid)
        on update cascade
        on delete restrict,
    foreign key (shelf_id) references shelf (shelf_id)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;

create table rate (
    `uid` int,
    bid int,
    rate_date date, -- TODO: or datetime?
    rating enum('0', '0.5', '1', '1.5', '2', '2.5', '3', '3.5', '4', '4.5', '5'),
    primary key (`uid`, bid), -- a user can change their rating, but each user only has 1 rating per book
    foreign key (`uid`) references user (`uid`)
        on update cascade
        on delete restrict,
    foreign key (bid) references book (bid)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;

create table review (
    `uid` int,
    bid int,
    rid int auto_increment, -- review id
    content varchar (400), -- TODO: longer? shorter?
    posted_by int unsigned, -- the id of the author of the review
    post_date datetime,
    primary key (rid), -- this way a user can post multiple reviews of a single book
    foreign key (`uid`) references user (`uid`)
        on update cascade
        on delete restrict,
    foreign key (bid) references book (bid)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;

create table reply (
    `uid` int,
    rid int,
    reply_date datetime,
    primary key (`uid`, rid, reply_date),
    foreign key (`uid`) references user (`uid`)
        on update cascade
        on delete restrict,
    foreign key (rid) references review (rid)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;
