[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_business.json /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -put hive-serdes-1.0-SNAPSHOT.jar /user/guan01/project/yelp/

beeline

!connect jdbc:hive2://192.168.1.13:10000/default

USE guan_db;

DROP TABLE Yelp_Business;

ADD JAR hdfs:/user/guan01/project/yelp/hive-serdes-1.0-SNAPSHOT.jar;


CREATE EXTERNAL TABLE Yelp_Business(
    business_id STRING,
    full_address STRING,
    open BOOLEAN,
    categories ARRAY<STRING>,
    city STRING,
    review_count INT,
    name STRING,
    neighborhoods ARRAY<STRING>,
    longitude DOUBLE,
    state STRING,
    stars DOUBLE,
    latitude DOUBLE,
    type STRING
    )
COMMENT 'DATA ABOUT businesss on yelp'
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/guan01/project/yelp/businessExternal';

SELECT full_address FROM Yelp_Business WHERE business_id = "FrBCYtCS_jydDjg1KsIgWQ";