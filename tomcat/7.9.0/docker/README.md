# Camunda BPM Tomcat 7.9.0 JSON Logging: Docker Image Pattern

A image which pulls Camunda 7.9.0-Tomcat and extends the image with proper configuration for Logging in a JSON format.

# JSON Logging

JSON logging is provided using the logstash-logback-encoded-5.2.jar and the relevant dependencies for SLF4j-api, logback, jul-to-slf4j, and jackson (for JSON processing).

Logback and slf4j-api dependencies were based on the [parent pom.xml](https://github.com/camunda/camunda-bpm-platform/blob/7.9.0/parent/pom.xml#L24-L25) from the camunda-bpm-platform repository for 7.9.0 tag.

# Performance

Note that in order to send the Tomcat/catalina logs into the JSON encoders, the `SLF4JBridgeHandler` (jul-to-slf4j-1.7.7.jar) is used within the global logging.properties file.  See the handlers [documentation for notes about performance](https://www.slf4j.org/api/org/slf4j/bridge/SLF4JBridgeHandler.html).  In order to mitigate the performance issues outlined in the Handler's documentation, the `LevelChangePropagator` is added into the logback configuration.  See the [logback documentation](https://logback.qos.ch/manual/configuration.html#LevelChangePropagator) for further notes about LevelChangePropagator's usage.

:exclamation: It is very important for Camunda Tomcat distribution logging that the LevelChangePropagator is used as described above!  It is already provided in the logback configuration file located in the docker/camunda/conf/logback folder.  If you make changes to this file, make sure to keep the LevelChangePropagator settings. :exclamation:


# How it works

The pattern is simple: 

1. Pull the Camunda BPM Platform 7.9.0 Tomcat image from DockerHub
2. Extend the image with relevant JSON logging configurations and Jars
3. Return a finalized image that is "the same" as the source image from Camunda's dockerhub, but with the added configuration and jars.

This image is posted on Dockerhub under

https://hub.docker.com/r/digitalstate/camunda-bpm-platform/

## JSON Logging Dependencies

A centralized package has been generated using maven in the `../json-logging-dependency-package` folder.  This package provides a single jar with all of the required jars needed for JSON logging using logback.

## Pull Image

Command Line:

`docker pull digitalstate/camunda-bpm-platform:tomcat-7.9.0-jsonlogging` 

Within another dockerfile:

```dockerfile
FROM digitalstate/camunda-bpm-platform:tomcat-7.9.0-jsonlogging
...
```

## Running Image:

Command Line: 

`docker run --name camunda -p 8080:8080 digitalstate/camunda-bpm-platform:tomcat-7.9.0-jsonlogging`

or use a dockerfile similar to the ./docker-compose.yml, but swap `build:` with `image: digitalstate/camunda-bpm-platform:tomcat-7.9.0-jsonlogging`

### Pretty-Print ENV Variable.

In the default logback.xml configuration, there has been a conditional statement added to support easy to use logging in Pretty-Print formatting.  This is typically used for development purposes:

`PRETTY_JSON_LOG=true` will enable the pretty-print.  By default, the env value is set to false.

Example:

`docker run --name camunda -p 8080:8080 -e PRETTY_JSON_LOG=true digitalstate/camunda-bpm-platform:tomcat-7.9.0-jsonlogging`


# Building a new image

`docker build -t digitalstate/camunda-bpm-platform:tomcat-7.9.0-jsonlogging .`


# docker-compose file usage

The docker-compose file can be used for quick testing locally.  Generally the docker-compose file will not be used.  The Dockerfile will be used to generate the image which will then be pulled from your own Dockerfile/Docker-Compose/Kubernetes.


# Custom logback.xml usage

In order to provide a custom logback.xml file, it is suggested that you use Docker Volumes; where the volume points to `/camunda/conf/logback` folder.  Within this folder you will provide the `logback.xml` file with your configuration.  See the docker/docker/conf/logback.logback.xml file for a working example/the default logback.xml file that is used.

## Pretty-Print JSON

By default pretty-print of the JSON is disabled.  This is to ensure maximum compatibility for production use of the base image.

In order to enable pretty-print of JSON (should only be used for debug/development purposes, due to performance impacts): in the camunda/conf/logback/logback.xml file, within the `json` `<appender>`, un-comment the line: 
```xml
<jsonGeneratorDecorator class="net.logstash.logback.decorate.PrettyPrintingJsonGeneratorDecorator"/>
```

The `PrettyPrintingJsonGeneratorDecorator` will then process the json into a pretty-print format within the console.

A Env variable has been added into the image (`PRETTY_JSON_LOG=false`) which can be set to true to enable Pretty-Print Json Logging.  This configuration is found through the logback.xml.  See the [Running Image](#running-image) section of this document for further information.

## Timestamp Customization: Timezone

See the logstash-logback-encoded [Timezone documentation](https://github.com/logstash/logstash-logback-encoder/tree/logstash-logback-encoder-5.2#customizing-timestamp) for details on how to customize the logback configuration for timezone conversions.

# Customize JSON format and content

The pattern uses the [Logstash-Logback-Encoder library v5.2](https://github.com/logstash/logstash-logback-encoder/tree/logstash-logback-encoder-5.2).  See the Readme of the library for further configuration options.


# Docker Logs

Logs are being sent into the docker console.  It will still be up to your deployment to configure docker logging to be in a JSON format.


# Sample JSON Output

```shell
$ docker run --name camunda -p 8080:8080 digitalstate/camunda-bpm-platform:tomcat-7.9.0-jsonlogging

Configure database
OpenJDK 64-Bit Server VM warning: ignoring option MaxPermSize=256m; support was removed in 8.0
OpenJDK 64-Bit Server VM warning: ignoring option PermSize=256m; support was removed in 8.0
16:57:07,194 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback.groovy]
16:57:07,194 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback-test.xml]
16:57:07,195 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Found resource [logback.xml] at [file:/camunda/conf/logback/logback.xml]
16:57:07,284 |-INFO in ch.qos.logback.classic.joran.action.ConfigurationAction - debug attribute not set
16:57:07,299 |-INFO in ch.qos.logback.classic.joran.action.LoggerContextListenerAction - Adding LoggerContextListener of type [ch.qos.logback.classic.jul.LevelChangePropagator] to the object stack
16:57:07,377 |-INFO in ch.qos.logback.classic.jul.LevelChangePropagator@770c2e6b - Propagating DEBUG level on Logger[ROOT] onto the JUL framework
16:57:07,378 |-INFO in ch.qos.logback.classic.joran.action.LoggerContextListenerAction - Starting LoggerContextListener
16:57:07,378 |-INFO in ch.qos.logback.core.joran.action.AppenderAction - About to instantiate appender of type [ch.qos.logback.core.ConsoleAppender]
16:57:07,384 |-INFO in ch.qos.logback.core.joran.action.AppenderAction - Naming appender as [STDOUT]
16:57:07,409 |-INFO in ch.qos.logback.core.joran.action.NestedComplexPropertyIA - Assuming default type [ch.qos.logback.classic.encoder.PatternLayoutEncoder] for [encoder] property
16:57:07,555 |-INFO in ch.qos.logback.core.joran.action.AppenderAction - About to instantiate appender of type [ch.qos.logback.core.ConsoleAppender]
16:57:07,555 |-INFO in ch.qos.logback.core.joran.action.AppenderAction - Naming appender as [json]
16:57:08,007 |-WARN in net.logstash.logback.encoder.LogstashEncoder@1a052a00 - Logback version is prior to 1.2.0.  Enabling backwards compatible encoding.  Logback 1.2.1 or greater is recommended.
16:57:08,008 |-INFO in ch.qos.logback.classic.joran.action.RootLoggerAction - Setting level of ROOT logger to INFO
16:57:08,008 |-INFO in ch.qos.logback.classic.jul.LevelChangePropagator@770c2e6b - Propagating INFO level on Logger[ROOT] onto the JUL framework
16:57:08,008 |-INFO in ch.qos.logback.core.joran.action.AppenderRefAction - Attaching appender named [json] to Logger[ROOT]
16:57:08,009 |-INFO in ch.qos.logback.classic.joran.action.ConfigurationAction - End of configuration.
16:57:08,011 |-INFO in ch.qos.logback.classic.joran.JoranConfigurator@4d826d77 - Registering current configuration as safe fallback point

{"@timestamp":"2018-08-07T16:57:08.864+00:00","@version":"1","message":"Server version:        Apache Tomcat/9.0.5","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.892+00:00","@version":"1","message":"Server built:          Feb 6 2018 21:42:23 UTC","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.893+00:00","@version":"1","message":"Server number:         9.0.5.0","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.894+00:00","@version":"1","message":"OS Name:               Linux","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.895+00:00","@version":"1","message":"OS Version:            4.9.93-linuxkit-aufs","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.896+00:00","@version":"1","message":"Architecture:          amd64","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.905+00:00","@version":"1","message":"Java Home:             /usr/lib/jvm/java-1.8-openjdk/jre","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.907+00:00","@version":"1","message":"JVM Version:           1.8.0_151-b12","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.908+00:00","@version":"1","message":"JVM Vendor:            Oracle Corporation","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.909+00:00","@version":"1","message":"CATALINA_BASE:         /camunda","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.913+00:00","@version":"1","message":"CATALINA_HOME:         /camunda","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.916+00:00","@version":"1","message":"Command line argument: -Djava.util.logging.config.file=/camunda/conf/logging.properties","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.917+00:00","@version":"1","message":"Command line argument: -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.918+00:00","@version":"1","message":"Command line argument: -Djdk.tls.ephemeralDHKeySize=2048","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.919+00:00","@version":"1","message":"Command line argument: -Djava.protocol.handler.pkgs=org.apache.catalina.webresources","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.920+00:00","@version":"1","message":"Command line argument: -Xmx512m","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.920+00:00","@version":"1","message":"Command line argument: -XX:MaxPermSize=256m","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.921+00:00","@version":"1","message":"Command line argument: -XX:PermSize=256m","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.921+00:00","@version":"1","message":"Command line argument: -Dignore.endorsed.dirs=","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.922+00:00","@version":"1","message":"Command line argument: -Dcatalina.base=/camunda","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.922+00:00","@version":"1","message":"Command line argument: -Dcatalina.home=/camunda","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.923+00:00","@version":"1","message":"Command line argument: -Djava.io.tmpdir=/camunda/temp","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:08.923+00:00","@version":"1","message":"The APR based Apache Tomcat Native library which allows optimal performance in production environments was not found on the java.library.path: [/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server:/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64:/usr/lib/jvm/java-1.8-openjdk/jre/../lib/amd64:/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib]","logger_name":"org.apache.catalina.core.AprLifecycleListener","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:09.223+00:00","@version":"1","message":"Initializing ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:09.260+00:00","@version":"1","message":"Using a shared selector for servlet write/read","logger_name":"org.apache.tomcat.util.net.NioSelectorPool","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:09.296+00:00","@version":"1","message":"Initializing ProtocolHandler [\"ajp-nio-8009\"]","logger_name":"org.apache.coyote.ajp.AjpNioProtocol","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:09.298+00:00","@version":"1","message":"Using a shared selector for servlet write/read","logger_name":"org.apache.tomcat.util.net.NioSelectorPool","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:09.299+00:00","@version":"1","message":"Initialization processed in 2470 ms","logger_name":"org.apache.catalina.startup.Catalina","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:09.869+00:00","@version":"1","message":"ENGINE-08046 Found camunda bpm platform configuration in CATALINA_BASE/CATALINA_HOME conf directory [/camunda/conf/bpm-platform.xml] at 'file:/camunda/conf/bpm-platform.xml'","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:10.707+00:00","@version":"1","message":"ENGINE-12003 Plugin 'ProcessApplicationEventListenerPlugin' activated on process engine 'default'","logger_name":"org.camunda.bpm.engine.cfg","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:10.739+00:00","@version":"1","message":"ENGINE-12003 Plugin 'SpinProcessEnginePlugin' activated on process engine 'default'","logger_name":"org.camunda.bpm.engine.cfg","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:10.759+00:00","@version":"1","message":"SPIN-01010 Discovered Spin data format provider: org.camunda.spin.impl.json.jackson.format.JacksonJsonDataFormatProvider[name = application/json]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:11.403+00:00","@version":"1","message":"SPIN-01010 Discovered Spin data format provider: org.camunda.spin.impl.xml.dom.format.DomXmlDataFormatProvider[name = application/xml]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:11.452+00:00","@version":"1","message":"SPIN-01009 Discovered Spin data format: org.camunda.spin.impl.xml.dom.format.DomXmlDataFormat[name = application/xml]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:11.453+00:00","@version":"1","message":"SPIN-01009 Discovered Spin data format: org.camunda.spin.impl.json.jackson.format.JacksonJsonDataFormat[name = application/json]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:11.453+00:00","@version":"1","message":"ENGINE-12003 Plugin 'ConnectProcessEnginePlugin' activated on process engine 'default'","logger_name":"org.camunda.bpm.engine.cfg","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:12.515+00:00","@version":"1","message":"CNCT-01004 Discovered provider for connector id 'http-connector' and class 'org.camunda.connect.httpclient.impl.HttpConnectorImpl': 'org.camunda.connect.httpclient.impl.HttpConnectorProviderImpl'","logger_name":"org.camunda.bpm.connect","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:12.530+00:00","@version":"1","message":"CNCT-01004 Discovered provider for connector id 'soap-http-connector' and class 'org.camunda.connect.httpclient.soap.impl.SoapHttpConnectorImpl': 'org.camunda.connect.httpclient.soap.impl.SoapHttpConnectorProviderImpl'","logger_name":"org.camunda.bpm.connect","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:19.680+00:00","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'engine' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.engine.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:19.774+00:00","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'history' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.history.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:19.813+00:00","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'identity' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.identity.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:19.850+00:00","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'case.engine' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.case.engine.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:19.861+00:00","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'case.history' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.case.history.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:19.873+00:00","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'decision.engine' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.decision.engine.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:19.889+00:00","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'decision.history' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.decision.history.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:19.999+00:00","@version":"1","message":"ENGINE-03067 No history level property found in database","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:20.001+00:00","@version":"1","message":"ENGINE-03065 Creating historyLevel property in database for level: HistoryLevelFull(name=full, id=3)","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:20.216+00:00","@version":"1","message":"ENGINE-00001 Process Engine default created.","logger_name":"org.camunda.bpm.engine","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:20.228+00:00","@version":"1","message":"ENGINE-14014 Starting up the JobExecutor[org.camunda.bpm.engine.impl.jobexecutor.RuntimeContainerJobExecutor].","logger_name":"org.camunda.bpm.engine.jobexecutor","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:20.238+00:00","@version":"1","message":"ENGINE-14018 JobExecutor[org.camunda.bpm.engine.impl.jobexecutor.RuntimeContainerJobExecutor] starting to acquire jobs","logger_name":"org.camunda.bpm.engine.jobexecutor","thread_name":"Thread-5","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:20.248+00:00","@version":"1","message":"ENGINE-08048 Camunda BPM platform sucessfully started at 'Apache Tomcat/9.0.5'.","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:20.337+00:00","@version":"1","message":"Starting service [Catalina]","logger_name":"org.apache.catalina.core.StandardService","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:20.348+00:00","@version":"1","message":"Starting Servlet Engine: Apache Tomcat/9.0.5","logger_name":"org.apache.catalina.core.StandardEngine","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:20.412+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/host-manager]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:24.632+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:24.824+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/host-manager] has finished in [4,411] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:24.827+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/examples]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:27.337+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:27.479+00:00","@version":"1","message":"ContextListener: contextInitialized()","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:27.484+00:00","@version":"1","message":"SessionListener: contextInitialized()","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:27.493+00:00","@version":"1","message":"ContextListener: attributeAdded('StockTicker', 'async.Stockticker@7a9dfe2c')","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:27.516+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/examples] has finished in [2,688] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:27.519+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/camunda-welcome]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:29.868+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:29.890+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/camunda-welcome] has finished in [2,371] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:29.891+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/ROOT]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:33.090+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:33.095+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/ROOT] has finished in [3,203] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:33.095+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/manager]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:35.566+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:35.570+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/manager] has finished in [2,474] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:35.570+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/docs]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:37.986+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:37.991+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/docs] has finished in [2,421] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:37.992+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/h2]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:40.037+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:40.065+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/h2] has finished in [2,073] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:40.067+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/camunda]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:42.400+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:42.983+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/camunda] has finished in [2,916] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:42.984+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/engine-rest]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:45.050+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:45.313+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/engine-rest] has finished in [2,329] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:45.315+00:00","@version":"1","message":"Deploying web application directory [/camunda/webapps/camunda-invoice]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:47.029+00:00","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:47.031+00:00","@version":"1","message":"ENGINE-07015 Detected @ProcessApplication class 'org.camunda.bpm.example.invoice.InvoiceProcessApplication'","logger_name":"org.camunda.bpm.application","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:47.062+00:00","@version":"1","message":"ENGINE-08024 Found processes.xml file at file:/camunda/webapps/camunda-invoice/WEB-INF/classes/META-INF/processes.xml","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:48.346+00:00","@version":"1","message":"ENGINE-07021 ProcessApplication 'camunda-invoice' registered for DB deployments [02a3d070-9a63-11e8-810e-0242ac110002]. Will execute process definitions \n\n        invoice[version: 1, id: invoice:1:02db3424-9a63-11e8-810e-0242ac110002]\n\nWill execute case definitions \n\n        ReviewInvoiceCase[version: 1, id: ReviewInvoiceCase:1:03292d16-9a63-11e8-810e-0242ac110002]\n","logger_name":"org.camunda.bpm.application","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:48.395+00:00","@version":"1","message":"ENGINE-08023 Deployment summary for process archive 'camunda-invoice': \n\n        invoiceBusinessDecisions.dmn\n        invoice.v2.bpmn\n        review-invoice.cmmn\n","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:48.685+00:00","@version":"1","message":"ENGINE-07021 ProcessApplication 'camunda-invoice' registered for DB deployments [02a3d070-9a63-11e8-810e-0242ac110002, 036e255a-9a63-11e8-810e-0242ac110002]. Will execute process definitions \n\n        invoice[version: 1, id: invoice:1:02db3424-9a63-11e8-810e-0242ac110002]\n        invoice[version: 2, id: invoice:2:037e51fe-9a63-11e8-810e-0242ac110002]\n\nWill execute case definitions \n\n        ReviewInvoiceCase[version: 1, id: ReviewInvoiceCase:1:03292d16-9a63-11e8-810e-0242ac110002]\n        ReviewInvoiceCase[version: 2, id: ReviewInvoiceCase:2:0386b670-9a63-11e8-810e-0242ac110002]\n","logger_name":"org.camunda.bpm.application","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:48.714+00:00","@version":"1","message":"SPIN-01010 Discovered Spin data format provider: org.camunda.spin.impl.json.jackson.format.JacksonJsonDataFormatProvider[name = application/json]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:48.718+00:00","@version":"1","message":"SPIN-01010 Discovered Spin data format provider: org.camunda.spin.impl.xml.dom.format.DomXmlDataFormatProvider[name = application/xml]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:48.721+00:00","@version":"1","message":"SPIN-01009 Discovered Spin data format: org.camunda.spin.impl.xml.dom.format.DomXmlDataFormat[name = application/xml]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:48.722+00:00","@version":"1","message":"SPIN-01009 Discovered Spin data format: org.camunda.spin.impl.json.jackson.format.JacksonJsonDataFormat[name = application/json]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:48.786+00:00","@version":"1","message":"Generating demo data for invoice showcase","logger_name":"org.camunda.bpm.example.invoice.DemoDataGenerator","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:49.977+00:00","@version":"1","message":"Start 3 instances of Invoice Receipt, version 1","logger_name":"org.camunda.bpm.example.invoice.InvoiceProcessApplication","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:53.905+00:00","@version":"1","message":"\n\n  ... Now notifying creditor Bobby's Office Supplies\n\n","logger_name":"org.camunda.bpm.example.invoice.service.NotifyCreditorService","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:55.167+00:00","@version":"1","message":"Start 3 instances of Invoice Receipt, version 2","logger_name":"org.camunda.bpm.example.invoice.InvoiceProcessApplication","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:56.376+00:00","@version":"1","message":"ENGINE-08050 Process application camunda-invoice successfully deployed","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:56.383+00:00","@version":"1","message":"Deployment of web application directory [/camunda/webapps/camunda-invoice] has finished in [11,067] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:56.421+00:00","@version":"1","message":"Starting ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:56.485+00:00","@version":"1","message":"Starting ProtocolHandler [\"ajp-nio-8009\"]","logger_name":"org.apache.coyote.ajp.AjpNioProtocol","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:57:56.494+00:00","@version":"1","message":"Server startup in 47233 ms","logger_name":"org.apache.catalina.startup.Catalina","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:58:15.607+00:00","@version":"1","message":"Deploying javax.ws.rs.core.Application: class org.camunda.bpm.tasklist.impl.web.TasklistApplication","logger_name":"org.jboss.resteasy.spi.ResteasyDeployment","thread_name":"http-nio-8080-exec-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:58:16.431+00:00","@version":"1","message":"Deploying javax.ws.rs.core.Application: class org.camunda.bpm.webapp.impl.engine.EngineRestApplication","logger_name":"org.jboss.resteasy.plugins.server.servlet.ServletContainerDispatcher","thread_name":"http-nio-8080-exec-10","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T16:58:16.480+00:00","@version":"1","message":"Deploying javax.ws.rs.core.Application: class org.camunda.bpm.admin.impl.web.AdminApplication","logger_name":"org.jboss.resteasy.plugins.server.servlet.ServletContainerDispatcher","thread_name":"http-nio-8080-exec-1","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}

$ ^C
load: 2.36  cmd: docker 35628 running 0.12u 0.19s

{"@timestamp":"2018-08-07T17:01:08.749+00:00","@version":"1","message":"ENGINE-14015 Shutting down the JobExecutor[org.camunda.bpm.engine.impl.jobexecutor.RuntimeContainerJobExecutor]","logger_name":"org.camunda.bpm.engine.jobexecutor","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:08.750+00:00","@version":"1","message":"ENGINE-14020 JobExecutor[org.camunda.bpm.engine.impl.jobexecutor.RuntimeContainerJobExecutor] stopped job acquisition","logger_name":"org.camunda.bpm.engine.jobexecutor","thread_name":"Thread-5","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:08.906+00:00","@version":"1","message":"ENGINE-08051 Process application camunda-invoice undeployed","logger_name":"org.camunda.bpm.container","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:08.953+00:00","@version":"1","message":"ENGINE-00007 Process Engine default closed","logger_name":"org.camunda.bpm.engine","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:08.957+00:00","@version":"1","message":"ENGINE-08049 Camunda BPM platform stopped at 'Apache Tomcat/9.0.5'","logger_name":"org.camunda.bpm.container","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:08.964+00:00","@version":"1","message":"Pausing ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:08.985+00:00","@version":"1","message":"Pausing ProtocolHandler [\"ajp-nio-8009\"]","logger_name":"org.apache.coyote.ajp.AjpNioProtocol","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:09.044+00:00","@version":"1","message":"Stopping service [Catalina]","logger_name":"org.apache.catalina.core.StandardService","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:09.204+00:00","@version":"1","message":"SessionListener: contextDestroyed()","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:09.206+00:00","@version":"1","message":"ContextListener: contextDestroyed()","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:09.237+00:00","@version":"1","message":"ENGINE-07017 Calling undeploy() on process application that is not deployed.","logger_name":"org.camunda.bpm.application","thread_name":"Thread-7","level":"WARN","level_value":30000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:09.397+00:00","@version":"1","message":"Stopping ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:09.412+00:00","@version":"1","message":"Stopping ProtocolHandler [\"ajp-nio-8009\"]","logger_name":"org.apache.coyote.ajp.AjpNioProtocol","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:09.423+00:00","@version":"1","message":"Destroying ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
{"@timestamp":"2018-08-07T17:01:09.429+00:00","@version":"1","message":"Destroying ProtocolHandler [\"ajp-nio-8009\"]","logger_name":"org.apache.coyote.ajp.AjpNioProtocol","thread_name":"Thread-7","level":"INFO","level_value":20000,"HOSTNAME":"760651e5c675"}
```