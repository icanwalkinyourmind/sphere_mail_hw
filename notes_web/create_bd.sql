 
create table notes (id bigint not null primary key, title varchar(40), note varchar(255) not null, create_time timestamp not null, index create_time_idx (create_time)) charset utf8;
create table owners (user_id int, note_id bigint,index  usr_id_idx (user_id),index  note_id_idx (note_id));
create table users (id int primary key auto_increment, username varchar(40), password varchar(40));
