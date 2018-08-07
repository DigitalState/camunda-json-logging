# Pull upstream CamundaBPM Tomcat image
FROM camunda/camunda-bpm-platform:tomcat-7.9.0

# Remove the slf4j-jdj14 bridge library that is packaged with CamundaBPM tomcat distribution
RUN rm -rf /camunda/lib/slf4j-jdk14-1.7.7.jar

# Add logback configuration
RUN mkdir /camunda/conf/logback
COPY docker/camunda/conf/logback/logback.xml /camunda/conf/logback/logback.xml

# Overwrite global logging configuration for tomcat
COPY docker/camunda/conf/logging.properties /camunda/conf/logging.properties

# Copy Jars for logging
COPY docker/camunda/lib/* /camunda/lib/

# Manual Copy of each jar in the lib folder; used for testing:
# Add logback and jul-to-slf4j libraries
# COPY docker/camunda/lib/jul-to-slf4j-1.7.7.jar /camunda/lib/jul-to-slf4j-1.7.7.jar
# COPY docker/camunda/lib/slf4j-api-1.7.7.jar /camunda/lib/slf4j-api-1.7.7.jar
# COPY docker/camunda/lib/logback-classic-1.1.2.jar /camunda/lib/logback-classic-1.1.2.jar
# COPY docker/camunda/lib/logback-core-1.1.2.jar /camunda/lib/logback-core-1.1.2.jar

# Add logstash-logback-encoder library 
# COPY docker/camunda/lib/logstash-logback-encoder-5.2.jar /camunda/lib/logstash-logback-encoder-5.2.jar

# Add JSON encoding libraries
# COPY docker/camunda/lib/jackson-core-2.9.6.jar /camunda/lib/jackson-core-2.9.6.jar
# COPY docker/camunda/lib/jackson-annotations-2.9.6.jar /camunda/lib/jackson-annotations-2.9.6.jar
# COPY docker/camunda/lib/jackson-databind-2.9.6.jar /camunda/lib/jackson-databind-2.9.6.jar

# Overwrite setenv.sh with additional CLASSPATH config that exposes the libraries at tomcat startup
COPY docker/camunda/bin/setenv.sh /camunda/bin/setenv.sh


