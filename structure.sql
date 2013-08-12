create table questions (
  id serial primary key,
  text varchar not null
);

create table answers (
  id serial primary key,
  question_id int not null references questions,
  text varchar not null
);

create index on answers (question_id);

create table products (
  id int primary key,
  counter int not null default 0,
  lock_version int not null default 0
);
