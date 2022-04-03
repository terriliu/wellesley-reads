use wellesleyreads_db;

drop table if exists reply;
drop table if exists review;
drop table if exists rate;
drop table if exists book;
drop table if exists befriend;
drop table if exists user;

create table user (
    `uid` int unsigned,
    uname varchar(10),
    pwd varchar(20),
    bio varchar(100),
    fav_genres set('romance', 'comedy', 'thriller', 'nonfiction', 'fiction', 'horror'), -- TODO: add more genres
    primary key (`uid`),
    index (uname)
)
ENGINE = InnoDB;

create table befriend (
    uid_1 int unsigned,
    uid_2 int unsigned,
    primary key (uid_1, uid_2),
    foreign key (uid_1) references user (`uid`)
        on update cascade
        on delete restrict,
    foreign key (uid_2) references user (`uid`)
        on update cascade
        on delete restrict
)
ENGINE = InnoDB;

create table book (
    bid int unsigned, -- book id
    bname varchar(20),
    author varchar(20),
    genre set('romance', 'comedy', 'thriller', 'nonfiction', 'fiction', 'horror'),
    avg_rating float unsigned,
    primary key (bid),
    index (bname)
)
ENGINE = InnoDB;

create table rate (
    `uid` int unsigned,
    bid int unsigned,
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
    `uid` int unsigned,
    bid int unsigned,
    rid int unsigned, -- review id
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
    `uid` int unsigned,
    rid int unsigned,
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
