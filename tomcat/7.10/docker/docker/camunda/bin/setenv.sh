export CATALINA_OPTS="-Xmx512m -XX:MaxPermSize=256m -XX:PermSize=256m"

# Sets the initial classpath to have the needed JUL->SLF4J jars + the logstash/Logback libraries
CLASSPATH=$CATALINA_HOME/lib/camunda-json-logging-tomcat-${CAMUNDA_VERSION}.jar:$CATALINA_HOME/conf/logback/