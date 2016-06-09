[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_user.json /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -put hive-serdes-1.0-SNAPSHOT.jar /user/guan01/project/yelp/

beeline

!connect jdbc:hive2://192.168.1.13:10000/default

USE guan_db;

DROP TABLE Yelp_User;

ADD JAR hdfs:/user/guan01/project/yelp/hive-serdes-1.0-SNAPSHOT.jar;


CREATE EXTERNAL TABLE Yelp_User(
    votes STRUCT<
                 useful:INT,  
                 funny:INT, 
                 cool:INT 
                >,
    user_id STRING,
    name STRING,
    average_stars DOUBLE,
    review_count INT,
    type STRING
    )
COMMENT 'DATA ABOUT user on yelp'
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/guan01/project/yelp/userExternal';

SELECT name AS NAME, average_stars AS STAR FROM Yelp_User WHERE average_stars > 4.9 LIMIT 10;