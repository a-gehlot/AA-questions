PRAGMA foreign_keys = 1;
DROP TABLE IF EXISTS question_tags;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

INSERT INTO
    users (fname, lname)
VALUES
    ("Vijay", "Gehlot"), ("Andrew", "Gehlot"), ("Spencer", "Christian");

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    author_id TEXT NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
    questions (title, body, author_id)
SELECT
    "FIRST COMMENT", "Hello this is the first comment", users.id
FROM
    users
WHERE
    users.fname = "Vijay" AND users.lname = "Gehlot";


INSERT INTO
    questions (title, body, author_id)
SELECT
    "SECOND COMMENT", "Hello this is the SECOND comment", users.id
FROM
    users
WHERE
    users.fname = "Andrew" AND users.lname = "Gehlot";

INSERT INTO
    questions
    (title, body, author_id)
SELECT
    "THIRD COMMENT", "Hello this is the third comment", users.id
FROM
    users
WHERE
    users.fname = "Sepncer" AND users.lname = "Christian";


CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id TEXT NOT NULL,
    question_id TEXT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
    question_follows (user_id, question_id)
VALUES 
    ((SELECT 
        id 
    FROM 
        users 
    WHERE 
        fname = "Andrew" AND lname = "Gehlot"),
    (SELECT 
        id 
    FROM 
        questions 
    WHERE 
        title = "FIRST COMMENT"));


CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    parent_id INTEGER,
    user_id INTEGER NOT NULL,
    body TEXT,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id)
);

INSERT INTO
    replies (question_id, parent_id, user_id, body)
VALUES
    ((SELECT
        id
    FROM
        questions
    WHERE
        title = "SECOND COMMENT"),
    NULL,
    (SELECT
        id 
    FROM  
        users
    WHERE
        fname = "Spencer" AND lname = "Christian"),
    "Wow this is a reply - my first reply!");

INSERT INTO
    replies (question_id, parent_id, user_id, body)
VALUES
    ((SELECT
        id 
    FROM
        questions
    WHERE
        title = "SECOND COMMENT"),
    (SELECT
        id
    FROM
        replies
    WHERE
        body = "Wow this is a reply - my first reply!"),
    (SELECT
        id 
    FROM
        users
    WHERE
        fname = "Vijay" AND lname = "Gehlot"),
    "This is a reply to the first reply!");


CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
    question_likes (question_id, user_id)
VALUES
    (1,2);
INSERT INTO
    question_likes (question_id, user_id)
VALUES
    (2,2);