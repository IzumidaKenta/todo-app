CREATE DATABASE sample;
USE sample;
CREATE TABLE todos(
    id int PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    checked bool NOT NULL
);
INSERT INTO todos(
    title,
    checked
) 
VALUES
(
    '洗濯取り込む',
    true
),
(
    '薄力粉',
    false
);
