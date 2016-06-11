[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_business.json /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -put hive-serdes-1.0-SNAPSHOT.jar /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/pigOutput


json_business_raw_row = LOAD 'hdfs:/user/guan01/project/yelp/businessExternal/yelp_training_set_business.json' as (str:chararray);

/*
first10 = LIMIT json_business_raw_row 10;
dump first10;
*/

/* 
get rid of "neighborhoods" attribute using Built In Functions: REPLACE
Replaces existing characters in a string with new characters.
Syntax: REPLACE(string, 'regExp', 'newChar');
string: The string to be updated.
'regExp': The regular expression to which the string is to be matched, in quotes.
'newChar': The new characters replacing the existing characters, in quotes.
If you want to replace special characters such as '[' in the string literal, it is necessary to escape them in 'regExp' by prefixing them with double backslashes (e.g. '\\[').
*/

json_business_raw_row_2 = FOREACH json_business_raw_row GENERATE REPLACE(str, '\\"neighborhoods\\"\\:\\s\\[\\],\\s', '') AS str;

/*
first10_2 = LIMIT json_business_raw_row_2 10;
dump first10_2;
*/

/*
REGEX_EXTRACT: Performs regular expression matching and extracts the matched group defined by an index parameter.
Syntax: REGEX_EXTRACT (string, regex, index)
string: The string in which to perform the match.
regex: The regular expression.
index: The index of the matched group to return.

Dot (.) means match any character.  Star (*) means zero or more times.  And question mark (?) means be greedy and keep going as long as the pattern 
still matches.  Put it all together, it means try and match any character, zero or more times, and get as many as you can.
*/

/* 
categories are key value pairs:
"categories": ["Print Media", "Mass Media"]
Key value pairs are separated by the pound sign # in Pig.
*/

json_business_raw_row_3 = FOREACH json_business_raw_row_2 GENERATE REPLACE(REPLACE(REGEX_EXTRACT(str, '\\"categories\\"\\:\\s\\[(.*?)\\]', 1), '\\"', ''),',',' #') AS categories , REPLACE(str, '\\"categories\\"\\:\\s\\[(.*?)\\],', '') AS str;

/*
first10_3 = LIMIT json_business_raw_row_3 10;
dump first10_3;
*/

json_business_row = FOREACH json_business_raw_row_3 GENERATE 
    REGEX_EXTRACT(str, '\\"business_id\\"\\:\\s\\"(.*?)\\"', 1) AS business_id, 
    REGEX_EXTRACT(str, '\\"name\\"\\:\\s\\"(.*?)\\"', 1) AS name, categories, 
    REGEX_EXTRACT(str, '\\"review_count\\"\\:\\s(.*?),', 1) AS review_count, 
    REGEX_EXTRACT(str, '\\"stars\\"\\:\\s(.*?),', 1) AS stars,
    REGEX_EXTRACT(str, '\\"open\\"\\:\\s(.*?),', 1) AS open,
    REPLACE(REPLACE(REGEX_EXTRACT(str, '\\"full_address\\"\\:\\s\\"(.*?)\\"', 1),'\\\\n','*'),'\\\\r','*') AS full_address,
    REGEX_EXTRACT(str, '\\"city\\"\\:\\s\\"(.*?)\\"', 1) AS city,
    REGEX_EXTRACT(str, '\\"state\\"\\:\\s\\"(.*?)\\"', 1) AS state,
    REGEX_EXTRACT(str, '\\"longitude\\"\\:\\s(.*?),', 1) AS longitude,
    REGEX_EXTRACT(str, '\\"latitude\\"\\:\\s(.*?),', 1) AS latitude;


STORE json_business_row INTO '/user/guan01/project/yelp/pigOutput/json_business_table';


STORE json_business_row INTO 'hdfs:///user/guan01/project/yelp/pigOutput/json_business_table' USING PigStorage('\u0001');

/*
http://mvnrepository.com/artifact/com.googlecode.json-simple/json-simple/1.1.1
http://mvnrepository.com/artifact/com.twitter.elephantbird
*/

REGISTER '/home/guan01/piggybank.jar'; 
REGISTER '/home/guan01/elephant-bird-hadoop-compat-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-core-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-pig-4.14-RC2.jar';
REGISTER '/home/guan01/json-simple-1.1.1.jar';

json_business_row_jsonLoader = LOAD '/user/guan01/project/yelp/businessExternal/yelp_training_set_business.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') AS (json:map []);

business_id = FOREACH json_business_row_jsonLoader GENERATE (chararray)json#'business_id' As business_id;
full_address = FOREACH json_business_row_jsonLoader GENERATE (chararray)json#'full_address' As full_address;
open = FOREACH json_business_row_jsonLoader GENERATE (boolean)json#'open' As open;
categories = FOREACH json_business_row_jsonLoader GENERATE TOMAP('categories',json#'categories') As categories;
city = FOREACH json_business_row_jsonLoader GENERATE (chararray)json#'city' As city;
review_count = FOREACH json_business_row_jsonLoader GENERATE (int)json#'review_count' As review_count;
name = FOREACH json_business_row_jsonLoader GENERATE (chararray)json#'name' As name;
longitude = FOREACH json_business_row_jsonLoader GENERATE (double)json#'longitude' As longitude;
state = FOREACH json_business_row_jsonLoader GENERATE (chararray)json#'state' As state;
stars = FOREACH json_business_row_jsonLoader GENERATE (double)json#'stars' As stars;
latitude = FOREACH json_business_row_jsonLoader GENERATE (double)json#'latitude' As latitude;


json_business_row = FOREACH json_business_row_jsonLoader GENERATE (chararray)json#'business_id' As business_id, (chararray)REPLACE(json#'full_address', '\\n', ', ') As full_address, (boolean)json#'open' As open, TOMAP('categories',json#'categories') As categories, (chararray)json#'city' As city, (int)json#'review_count' As review_count, (chararray)json#'name' As name, (double)json#'longitude' As longitude, (chararray)json#'state' As state, (double)json#'stars' As stars, (double)json#'latitude' As latitude;

STORE json_business_row INTO 'hdfs:///user/guan01/project/yelp/pigOutput/json_business_table' USING PigStorage('\u0001');


split json_business_row into group1 if stars < 3.0, group2 if stars > 4.8, group3 otherwise;
dump group1;

json_business_raw_row_2 = FOREACH json_business_raw_row GENERATE REPLACE(str, '\\"neighborhoods\\"\\:\\s\\[\\],\\s', '') AS str;
full_address_2 = FOREACH json_business_row_jsonLoader GENERATE (chararray)REPLACE(json#'full_address', '\\n', ', ') As full_address;

json_business_row = FOREACH json_business_row_jsonLoader GENERATE TOBAG(business_id, full_address, open, categories, city, review_count, name, longitude, state, stars, latitude) AS bag1;

json_business_row = Foreach business_id, full_address, open, categories, city, Generate TOBAG(p1, p2, p3, p4, p5) as bag1

business_id, full_address, open, categories, city, review_count, name, longitude, state, stars, latitude 

B = group business_id all;
C = foreach B generate COUNT(business_id);
dump C;


business_row_1 = FOREACH json_business_row_jsonLoader GENERATE json#'business' As business_row;
user_followers = FOREACH user_details GENERATE (chararray)tweetUser#'screen_name' As screenName, (int)tweetUser#'followers_count' As followersCount;

B = FOREACH loadJson GENERATE flatten(json#'tweets') as (m:map[]);
C = FOREACH B GENERATE FLATTEN(m#'text');
DUMP C;

categories_1 = FOREACH json_business_row_jsonLoader GENERATE (map[])json#'categories' As categories_1_tmp;
categories = FOREACH categories_1 GENERATE FLATTEN(categories_1_tmp) AS categories;

('business_id:chararray, name:chararray, categories:map[], review_count:int, stars:double, open:boolean, full_address:chararray, city:chararray, state:chararray, longitude:double, latitude:double');






REGISTER '/home/guan01/piggybank.jar'; 

json_business_row_jsonLoader = LOAD 'hdfs:/user/guan01/project/yelp/businessExternal/yelp_training_set_business.json' USING org.apache.pig.piggybank.storage.JsonLoader('business_id:chararray, name:chararray, categories:map[], review_count:int, stars:double, open:boolean, full_address:chararray, city:chararray, state:chararray, longitude:double, latitude:double');







