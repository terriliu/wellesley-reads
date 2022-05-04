use wellesleyreads_db;

drop table if exists reply;
drop table if exists review;
drop table if exists book_on_shelf;
drop table if exists shelf;
drop table if exists book;
drop table if exists author;
drop table if exists befriend;
drop table if exists user;
drop table if exists userpass;


create table user (
    `uid` int auto_increment,
    uname varchar(50) not null,
    hashed char(60),
    bio varchar(100),
    fav_genres set('romance', 'mystery', 'science-fiction', 'nonfiction', 'fiction', 'horror'), -- TODO: add more genres
    primary key (`uid`),
    unique(uname),
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
    aid int,
    genre set('romance', 'mystery', 'science-fiction', 'nonfiction', 'fiction', 'horror'),
    avg_rating float unsigned,
    primary key (bid),
    index (bname),
    foreign key (aid) references author (aid)
        on update cascade
        on delete restrict
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

create table review (
    `uid` int,
    bid int,
    review_id int auto_increment, -- review id
    rating float unsigned,
    content varchar (400), -- TODO: longer? shorter?
    post_date datetime,
    primary key (review_id), -- this way a user can post multiple reviews of a single book
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
    reply_id int auto_increment,
    reply_date datetime,
    review_id int,
    content varchar(400),
    primary key (reply_id),
    foreign key (`uid`) references user (`uid`)
        on update cascade
        on delete restrict,
    foreign key (review_id) references review (review_id)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;
