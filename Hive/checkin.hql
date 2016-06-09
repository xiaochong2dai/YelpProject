[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_checkin.json /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -put hive-serdes-1.0-SNAPSHOT.jar /user/guan01/project/yelp/

beeline

!connect jdbc:hive2://192.168.1.13:10000/default

USE guan_db;

DROP TABLE Yelp_Checkin;

ADD JAR hdfs:/user/guan01/project/yelp/hive-serdes-1.0-SNAPSHOT.jar;


CREATE EXTERNAL TABLE Yelp_Checkin(
    checkin_info MAP<STRING, INT>,
    type STRING,
    business_id STRING
    )
COMMENT 'DATA ABOUT checkin on yelp'
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/guan01/project/yelp/checkinExternal';

SELECT checkin_info FROM Yelp_Checkin WHERE business_id = "l4ymgiD1WnsSrwxWWk7a3Q";

// search value based on key since checkin_info is a map type
SELECT checkin_info["12-4"] FROM Yelp_Checkin WHERE business_id = "l4ymgiD1WnsSrwxWWk7a3Q";

SELECT checkin_info["10-2"] AS value FROM Yelp_Checkin WHERE business_id = "l4ymgiD1WnsSrwxWWk7a3Q";