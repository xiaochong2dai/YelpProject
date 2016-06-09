// beeline at local cloudera VM
!connect jdbc:hive2://localhost:10000/default

  Enter username for jdbc:hive2://localhost:10000/default: <Press Enter>
  Enter password for jdbc:hive2://localhost:10000/default: <press Enter>


[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/reviewExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_review.json /user/guan01/project/yelp/reviewExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/reviewExternal
[guan01@master1 ~]$ hadoop fs -put hive-serdes-1.0-SNAPSHOT.jar /user/guan01/project/yelp/

beeline

!connect jdbc:hive2://192.168.1.13:10000/default

USE guan_db;

DROP TABLE Yelp_Review;

ADD JAR hdfs:/user/guan01/project/yelp/hive-serdes-1.0-SNAPSHOT.jar;

CREATE EXTERNAL TABLE Yelp_Review(
    votes STRUCT<
                 useful:INT,  
                 funny:INT, 
                 cool:INT 
                >,
    user_id STRING,
    review_id STRING,
    stars INT,
    `date` STRING,
    text STRING,
    type STRING,
    business_id STRING
)
COMMENT 'DATA ABOUT review on yelp'
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/guan01/project/yelp/reviewExternal';

SELECT user_id FROM Yelp_Review WHERE `date` = "2010-03-28";
