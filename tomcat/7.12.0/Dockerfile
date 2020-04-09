FROM camunda/camunda-bpm-platform:tomcat-7.12.0

RUN rm -rf /camunda/webapps/camunda-invoice

ENV PRETTY_JSON_LOG=false

# Remove the slf4j-jdj14 bridge library that is packaged with CamundaBPM tomcat distribution
RUN rm -rf /camunda/lib/slf4j-jdk14-1.7.26.jar

# Add logback configuration
RUN mkdir /camunda/conf/logback
COPY docker/conf/logback/logback.xml /camunda/conf/logback/logback.xml

# Overwrite global logging configuration for tomcat
COPY docker/conf/logging.properties /camunda/conf/logging.properties

# Copy Jar for logging
COPY docker/lib/ /camunda/lib/

# Overwrite setenv.sh with additional CLASSPATH config that exposes the libraries at tomcat startup
COPY docker/bin/setenv.sh /camunda/bin/setenv.sh
