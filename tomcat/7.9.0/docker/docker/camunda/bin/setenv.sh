export CATALINA_OPTS="-Xmx512m -XX:MaxPermSize=256m -XX:PermSize=256m"

# Sets the initial classpath to have the needed JUL->SLF4J jars + the logstash/Logback libraries
CLASSPATH=$CATALINA_HOME/lib/jul-to-slf4j-1.7.7.jar:$CATALINA_HOME/lib/slf4j-api-1.7.7.jar:$CATALINA_HOME/lib/logback-classic-1.1.2.jar:$CATALINA_HOME/lib/logback-core-1.1.2.jar:$CATALINA_HOME/lib/jackson-core-2.9.6.jar:$CATALINA_HOME/lib/jackson-annotations-2.9.6.jar:$CATALINA_HOME/lib/jackson-databind-2.9.6.jar:$CATALINA_HOME/lib/logstash-logback-encoder-5.2.jar:$CATALINA_HOME/conf/logback/