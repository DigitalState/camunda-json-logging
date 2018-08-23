export CATALINA_OPTS="-Xmx512m -XX:MaxPermSize=256m -XX:PermSize=256m"

# Sets the initial classpath to have the needed JUL->SLF4J jars + the logstash/Logback libraries
CLASSPATH=$CATALINA_HOME/lib/camunda-json-logging-tomcat-7.9.0-1.0.jar:$CATALINA_HOME/conf/logback/