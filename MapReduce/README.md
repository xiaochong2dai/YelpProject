# Steps:

1. mvn clean
2. mvn package
3. hadoop fs -ls /user/cloudera/YelpProject
4. hadoop fs -ls /user/cloudera/YelpProject/input
5. hadoop fs -ls /user/cloudera/YelpProject/input/1
6. hadoop fs -ls /user/cloudera/YelpProject/output
# in the folder where yelp_training_set_business.json locates
7. hadoop fs -copyFromLocal yelp_training_set_business.json /user/cloudera/YelpProject/input/1
# check if file has been successfully uploaded
8. hadoop fs -ls /user/cloudera/YelpProject/input/1
# go to YelpProject folder
9. hadoop jar target/YelpProject-0.0.1-SNAPSHOT.jar MapReduce.Demo /user/cloudera/YelpProject/input/1 /user/cloudera/YelpProject/output
10. hadoop fs -cat /user/cloudera/YelpProject/output/* > business.txt      




For testing purpose, I run all the commands together to save time<br/>
mvn clean; mvn package; hadoop jar target/YelpProject-0.0.1-SNAPSHOT.jar MapReduce.Demo /user/cloudera/YelpProject/input/1 /user/cloudera/YelpProject/output; hadoop fs -cat /user/cloudera/YelpProject/output/* > business.txt
 
