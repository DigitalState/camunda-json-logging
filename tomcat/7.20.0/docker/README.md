# Camunda BPM Tomcat 7.20.0 JSON Logging: Docker Image Pattern

A image which pulls Camunda 7.20.0-Tomcat and extends the image with proper configuration for Logging in a JSON format.

# JSON Logging

JSON logging is provided using the logstash-logback-encoded-7.4.jar and the relevant dependencies for SLF4j-api, logback, jul-to-slf4j.

Logback and slf4j-api dependencies are bumped up to be compatible with Camunda 7.20.0. 

# Performance

Note that in order to send the Tomcat/catalina logs into the JSON encoders, the `SLF4JBridgeHandler` (jul-to-slf4j-2.0.11.jar) is used within the global logging.properties file.  See the handlers [documentation for notes about performance](https://www.slf4j.org/api/org/slf4j/bridge/SLF4JBridgeHandler.html).  In order to mitigate the performance issues outlined in the Handler's documentation, the `LevelChangePropagator` is added into the logback configuration.  See the [logback documentation](https://logback.qos.ch/manual/configuration.html#LevelChangePropagator) for further notes about LevelChangePropagator's usage.

:exclamation: It is very important for Camunda Tomcat distribution logging that the LevelChangePropagator is used as described above!  It is already provided in the logback configuration file located in the docker/camunda/conf/logback folder.  If you make changes to this file, make sure to keep the LevelChangePropagator settings. :exclamation:


# How it works

The pattern is simple: 

1. Pull the Camunda BPM Platform 7.20.0 Tomcat image from DockerHub
2. Extend the image with relevant JSON logging configurations and Jars
3. Return a finalized image that is "the same" as the source image from Camunda's dockerhub, but with the added configuration and jars.

This image is posted on Dockerhub under

https://hub.docker.com/r/digitalstate/camunda-bpm-platform/

## JSON Logging Dependencies

A centralized package has been generated using maven in the `../json-logging-dependency-package` folder.  This package provides a single jar with all of the required jars needed for JSON logging using logback.

## Pull Image

Command Line:

`docker pull digitalstate/camunda-bpm-platform:tomcat-7.20.0-json-logging` 

Within another dockerfile:

```dockerfile
FROM digitalstate/camunda-bpm-platform:tomcat-7.20.0-json-logging
...
```

## Running Image:

Command Line: 

`docker run --name camunda -p 8080:8080 digitalstate/camunda-bpm-platform:tomcat-7.20.0-json-logging`

or use a dockerfile similar to the ./docker-compose.yml, but swap `build:` with `image: digitalstate/camunda-bpm-platform:tomcat-7.20.0-json-logging`

### Pretty-Print ENV Variable.

In the default logback.xml configuration, there has been a conditional statement added to support easy to use logging in Pretty-Print formatting.  This is typically used for development purposes:

`PRETTY_JSON_LOG=true` will enable the pretty-print.  By default, the env value is set to false.

Example:

`docker run --name camunda -p 8080:8080 -e PRETTY_JSON_LOG=true digitalstate/camunda-bpm-platform:tomcat-7.20.0-json-logging`


# Building a new image

`docker build -t digitalstate/camunda-bpm-platform:tomcat-7.20.0-json-logging .`


# docker-compose file usage

The docker-compose file can be used for quick testing locally.  Generally the docker-compose file will not be used.  The Dockerfile will be used to generate the image which will then be pulled from your own Dockerfile/Docker-Compose/Kubernetes.


# Custom logback.xml usage

In order to provide a custom logback.xml file, it is suggested that you use Docker Volumes; where the volume points to `/camunda/conf/logback` folder.  Within this folder you will provide the `logback.xml` file with your configuration.  See the docker/docker/conf/logback.logback.xml file for a working example/the default logback.xml file that is used.

A 30 second refresh has been configured on the logback.xml file.  If the file is changed through a volume, you can make updates to the logging configuration without having to restart the Camunda docker container.
See the logback.xml file for further details.

## Pretty-Print JSON

By default pretty-print of the JSON is disabled.  This is to ensure maximum compatibility for production use of the base image.

In order to enable pretty-print of JSON (should only be used for debug/development purposes, due to performance impacts): in the camunda/conf/logback/logback.xml file, within the `json` `<appender>`, un-comment the line: 
```xml
<jsonGeneratorDecorator class="net.logstash.logback.decorate.PrettyPrintingJsonGeneratorDecorator"/>
```

The `PrettyPrintingJsonGeneratorDecorator` will then process the json into a pretty-print format within the console.

A Env variable has been added into the image (`PRETTY_JSON_LOG=false`) which can be set to true to enable Pretty-Print Json Logging.  This configuration is found through the logback.xml.  See the [Running Image](#running-image) section of this document for further information.

## Timestamp Customization: Timezone

See the logstash-logback-encoded [Timezone documentation](https://github.com/logstash/logstash-logback-encoder/tree/logstash-logback-encoder-7.4#customizing-timestamp) for details on how to customize the logback configuration for timezone conversions.

# Customize JSON format and content

The pattern uses the [Logstash-Logback-Encoder library v7.4](https://github.com/logstash/logstash-logback-encoder/tree/logstash-logback-encoder-7.4).  See the Readme of the library for further configuration options.


# Docker Logs

Logs are being sent into the docker console.  It will still be up to your deployment to configure docker logging to be in a JSON format.


# Sample JSON Output

```shell
$ docker run --name camunda -p 8080:8080 digitalstate/camunda-bpm-platform:tomcat-7.20.0-json-logging
Configure database
NOTE: Picked up JDK_JAVA_OPTIONS:  --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED
NOTE: Picked up JDK_JAVA_OPTIONS:  --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED
11:05:47,273 |-INFO in ch.qos.logback.classic.LoggerContext[default] - This is logback-classic version ?
11:05:47,274 |-INFO in ch.qos.logback.classic.util.ContextInitializer@7674b62c - No custom configurators were discovered as a service.
11:05:47,274 |-INFO in ch.qos.logback.classic.util.ContextInitializer@7674b62c - Trying to configure with ch.qos.logback.classic.joran.SerializedModelConfigurator
11:05:47,275 |-INFO in ch.qos.logback.classic.util.ContextInitializer@7674b62c - Constructed configurator of type class ch.qos.logback.classic.joran.SerializedModelConfigurator
11:05:47,277 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback-test.scmo]
11:05:47,278 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback.scmo]
11:05:47,283 |-INFO in ch.qos.logback.classic.util.ContextInitializer@7674b62c - ch.qos.logback.classic.joran.SerializedModelConfigurator.configure() call lasted 3 milliseconds. ExecutionStatus=INVOKE_NEXT_IF_ANY
11:05:47,283 |-INFO in ch.qos.logback.classic.util.ContextInitializer@7674b62c - Trying to configure with ch.qos.logback.classic.util.DefaultJoranConfigurator
11:05:47,283 |-INFO in ch.qos.logback.classic.util.ContextInitializer@7674b62c - Constructed configurator of type class ch.qos.logback.classic.util.DefaultJoranConfigurator
11:05:47,283 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback-test.xml]
11:05:47,286 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Found resource [logback.xml] at [file:/camunda/conf/logback/logback.xml]
11:05:47,322 |-WARN in IfNestedWithinSecondPhaseElementSC - <if> elements cannot be nested within an <appender>, <logger> or <root> element
11:05:47,322 |-WARN in IfNestedWithinSecondPhaseElementSC - See also http://logback.qos.ch/codes.html#nested_if_element
11:05:47,328 |-WARN in IfNestedWithinSecondPhaseElementSC - Element <appender> at line 16 contains a nested <if> element at line 18
11:05:47,362 |-INFO in ch.qos.logback.classic.model.processor.ConfigurationModelHandlerFull - Registering a new ReconfigureOnChangeTask ReconfigureOnChangeTask(born:1704884747361)
11:05:47,363 |-INFO in ch.qos.logback.classic.model.processor.ConfigurationModelHandlerFull - Will scan for changes in [file:/camunda/conf/logback/logback.xml]
11:05:47,363 |-INFO in ch.qos.logback.classic.model.processor.ConfigurationModelHandlerFull - Setting ReconfigureOnChangeTask scanning period to 30 seconds
11:05:47,366 |-INFO in ch.qos.logback.classic.model.processor.LoggerContextListenerModelHandler - Adding LoggerContextListener of type [ch.qos.logback.classic.jul.LevelChangePropagator] to the object stack
11:05:47,370 |-INFO in ch.qos.logback.classic.jul.LevelChangePropagator@19e7a160 - Propagating DEBUG level on Logger[ROOT] onto the JUL framework
11:05:47,370 |-INFO in ch.qos.logback.classic.model.processor.LoggerContextListenerModelHandler - Starting LoggerContextListener
11:05:47,371 |-WARN in ch.qos.logback.core.model.processor.AppenderModelHandler - Appender named [STDOUT] not referenced. Skipping further processing.
11:05:47,371 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [json]
11:05:47,371 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.core.ConsoleAppender]
11:05:47,466 |-INFO in ch.qos.logback.core.model.processor.conditional.IfModelHandler - Condition [false] evaluated to false on line 18
11:05:47,567 |-INFO in ch.qos.logback.classic.model.processor.RootLoggerModelHandler - Setting level of ROOT logger to INFO
11:05:47,567 |-INFO in ch.qos.logback.classic.jul.LevelChangePropagator@19e7a160 - Propagating INFO level on Logger[ROOT] onto the JUL framework
11:05:47,567 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [json] to Logger[ROOT]
11:05:47,567 |-INFO in ch.qos.logback.core.model.processor.DefaultProcessor@662706a7 - End of configuration.
11:05:47,568 |-INFO in ch.qos.logback.classic.joran.JoranConfigurator@45a4b042 - Registering current configuration as safe fallback point
11:05:47,568 |-INFO in ch.qos.logback.classic.util.ContextInitializer@7674b62c - ch.qos.logback.classic.util.DefaultJoranConfigurator.configure() call lasted 285 milliseconds. ExecutionStatus=DO_NOT_INVOKE_NEXT_IF_ANY

SLF4J(W): A number (100) of logging calls during the initialization phase have been intercepted and are
SLF4J(W): now being replayed. These are subject to the filtering rules of the underlying logging system.
SLF4J(W): See also https://www.slf4j.org/codes.html#replay
{"@timestamp":"2024-01-10T11:05:47.639689933Z","@version":"1","message":"Server version name:   Apache Tomcat/9.0.75","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.645425804Z","@version":"1","message":"Server built:          May 4 2023 13:04:05 UTC","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.645669848Z","@version":"1","message":"Server version number: 9.0.75.0","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.645915926Z","@version":"1","message":"OS Name:               Linux","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.646124493Z","@version":"1","message":"OS Version:            5.15.133.1-microsoft-standard-WSL2","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.646351775Z","@version":"1","message":"Architecture:          amd64","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.646498133Z","@version":"1","message":"Java Home:             /usr/lib/jvm/java-17-openjdk","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.6466595Z","@version":"1","message":"JVM Version:           17.0.8+7-alpine-r0","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.646852928Z","@version":"1","message":"JVM Vendor:            Alpine","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.647013003Z","@version":"1","message":"CATALINA_BASE:         /camunda","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.647188597Z","@version":"1","message":"CATALINA_HOME:         /camunda","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.653587589Z","@version":"1","message":"Command line argument: --add-opens=java.base/java.lang=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.653804071Z","@version":"1","message":"Command line argument: --add-opens=java.base/java.io=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.653993711Z","@version":"1","message":"Command line argument: --add-opens=java.base/java.util=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.654228177Z","@version":"1","message":"Command line argument: --add-opens=java.base/java.util.concurrent=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.654392059Z","@version":"1","message":"Command line argument: --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.654543317Z","@version":"1","message":"Command line argument: --add-opens=java.base/java.lang=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.654719542Z","@version":"1","message":"Command line argument: --add-opens=java.base/java.io=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.654874126Z","@version":"1","message":"Command line argument: --add-opens=java.base/java.util=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.655078555Z","@version":"1","message":"Command line argument: --add-opens=java.base/java.util.concurrent=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.655218481Z","@version":"1","message":"Command line argument: --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.655336265Z","@version":"1","message":"Command line argument: -Djava.util.logging.config.file=/camunda/conf/logging.properties","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.655467675Z","@version":"1","message":"Command line argument: -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.655586491Z","@version":"1","message":"Command line argument: -Djdk.tls.ephemeralDHKeySize=2048","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.65569116Z","@version":"1","message":"Command line argument: -Djava.protocol.handler.pkgs=org.apache.catalina.webresources","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.655807452Z","@version":"1","message":"Command line argument: -Dorg.apache.catalina.security.SecurityListener.UMASK=0027","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.655913744Z","@version":"1","message":"Command line argument: -Xmx512m","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.656079369Z","@version":"1","message":"Command line argument: -Dignore.endorsed.dirs=","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.656226809Z","@version":"1","message":"Command line argument: -Dcatalina.base=/camunda","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.656438993Z","@version":"1","message":"Command line argument: -Dcatalina.home=/camunda","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.656562368Z","@version":"1","message":"Command line argument: -Djava.io.tmpdir=/camunda/temp","logger_name":"org.apache.catalina.startup.VersionLoggerListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.657757701Z","@version":"1","message":"The Apache Tomcat Native library which allows using OpenSSL was not found on the java.library.path: [/usr/lib/jvm/java-17-openjdk/lib/server:/usr/lib/jvm/java-17-openjdk/lib:/usr/lib/jvm/java-17-openjdk/../lib:/usr/java/packages/lib:/usr/lib64:/lib64:/lib:/usr/lib]","logger_name":"org.apache.catalina.core.AprLifecycleListener","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.850492015Z","@version":"1","message":"Initializing ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:47.870392282Z","@version":"1","message":"Server initialization in [694] milliseconds","logger_name":"org.apache.catalina.startup.Catalina","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.123425146Z","@version":"1","message":"ENGINE-08046 Found Camunda Platform configuration in CATALINA_BASE/CATALINA_HOME conf directory [/camunda/conf/bpm-platform.xml] at 'file:/camunda/conf/bpm-platform.xml'","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.22348295Z","@version":"1","message":"ENGINE-12003 Plugin 'ProcessApplicationEventListenerPlugin' activated on process engine 'default'","logger_name":"org.camunda.bpm.engine.cfg","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.227895673Z","@version":"1","message":"ENGINE-12003 Plugin 'SpinProcessEnginePlugin' activated on process engine 'default'","logger_name":"org.camunda.bpm.engine.cfg","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.231487245Z","@version":"1","message":"SPIN-01010 Discovered Spin data format provider: org.camunda.spin.impl.json.jackson.format.JacksonJsonDataFormatProvider[name = application/json]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.360539873Z","@version":"1","message":"SPIN-01010 Discovered Spin data format provider: org.camunda.spin.impl.xml.dom.format.DomXmlDataFormatProvider[name = application/xml]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.428865608Z","@version":"1","message":"SPIN-01009 Discovered Spin data format: org.camunda.spin.impl.xml.dom.format.DomXmlDataFormat[name = application/xml]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.429103521Z","@version":"1","message":"SPIN-01009 Discovered Spin data format: org.camunda.spin.impl.json.jackson.format.JacksonJsonDataFormat[name = application/json]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.429222588Z","@version":"1","message":"ENGINE-12003 Plugin 'ConnectProcessEnginePlugin' activated on process engine 'default'","logger_name":"org.camunda.bpm.engine.cfg","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.61121938Z","@version":"1","message":"CNCT-01004 Discovered provider for connector id 'http-connector' and class 'org.camunda.connect.httpclient.impl.HttpConnectorImpl': 'org.camunda.connect.httpclient.impl.HttpConnectorProviderImpl'","logger_name":"org.camunda.bpm.connect","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.613937441Z","@version":"1","message":"CNCT-01004 Discovered provider for connector id 'soap-http-connector' and class 'org.camunda.connect.httpclient.soap.impl.SoapHttpConnectorImpl': 'org.camunda.connect.httpclient.soap.impl.SoapHttpConnectorProviderImpl'","logger_name":"org.camunda.bpm.connect","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.731747462Z","@version":"1","message":"FEEL/SCALA-01001 Spin value mapper detected","logger_name":"org.camunda.bpm.dmn.feel.scala","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:48.807090647Z","@version":"1","message":"Engine created. [value-mapper: CompositeValueMapper(List(org.camunda.feel.impl.JavaValueMapper@2a47597, org.camunda.spin.plugin.impl.feel.integration.SpinValueMapper@12f279b5)), function-provider: org.camunda.bpm.dmn.feel.impl.scala.function.CustomFunctionTransformer@7b2bf745, clock: SystemClock, configuration: Configuration(false)]","logger_name":"org.camunda.feel.FeelEngine","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.714517428Z","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'engine' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.engine.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.756167494Z","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'history' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.history.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.767853936Z","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'identity' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.identity.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.779467006Z","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'case.engine' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.case.engine.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.783672065Z","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'case.history' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.case.history.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.788203034Z","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'decision.engine' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.decision.engine.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.794336631Z","@version":"1","message":"ENGINE-03016 Performing database operation 'create' on component 'decision.history' with resource 'org/camunda/bpm/engine/db/create/activiti.h2.create.decision.history.sql'","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.826952869Z","@version":"1","message":"ENGINE-03067 No history level property found in database","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.830100251Z","@version":"1","message":"ENGINE-03065 Creating historyLevel property in database for level: HistoryLevelFull(name=full, id=3)","logger_name":"org.camunda.bpm.engine.persistence","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.905843602Z","@version":"1","message":"ENGINE-00001 Process Engine default created.","logger_name":"org.camunda.bpm.engine","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.907036732Z","@version":"1","message":"ENGINE-14014 Starting up the JobExecutor[org.camunda.bpm.engine.impl.jobexecutor.RuntimeContainerJobExecutor].","logger_name":"org.camunda.bpm.engine.jobexecutor","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.908602606Z","@version":"1","message":"ENGINE-14018 JobExecutor[org.camunda.bpm.engine.impl.jobexecutor.RuntimeContainerJobExecutor] starting to acquire jobs","logger_name":"org.camunda.bpm.engine.jobexecutor","thread_name":"Thread-3","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.909167726Z","@version":"1","message":"ENGINE-08048 Camunda Platform sucessfully started at 'Apache Tomcat/9.0.75'.","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.925474866Z","@version":"1","message":"Starting service [Catalina]","logger_name":"org.apache.catalina.core.StandardService","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.926075138Z","@version":"1","message":"Starting Servlet engine: [Apache Tomcat/9.0.75]","logger_name":"org.apache.catalina.core.StandardEngine","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:50.935162273Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/engine-rest]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:53.152253309Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:53.2960277Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/engine-rest] has finished in [2,361] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:53.296407653Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/host-manager]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:54.58982913Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:54.594181249Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/host-manager] has finished in [1,297] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:54.594426686Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/examples]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:55.940177456Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:55.961265128Z","@version":"1","message":"ContextListener: contextInitialized()","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:55.961566422Z","@version":"1","message":"SessionListener: contextInitialized()","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:55.962745865Z","@version":"1","message":"ContextListener: attributeAdded('StockTicker', 'async.Stockticker@72eac706')","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:55.969048954Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/examples] has finished in [1,374] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:55.96955154Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/camunda-welcome]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:57.204273388Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:57.205845689Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/camunda-welcome] has finished in [1,236] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:57.20605673Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/docs]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:58.335283783Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:58.337117742Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/docs] has finished in [1,131] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:58.337362678Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/ROOT]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:59.447218651Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:59.44864272Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/ROOT] has finished in [1,111] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:05:59.448877627Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/camunda-invoice]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.555298697Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.555686545Z","@version":"1","message":"ENGINE-07015 Detected @ProcessApplication class 'org.camunda.bpm.example.invoice.InvoiceProcessApplication'","logger_name":"org.camunda.bpm.application","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.560855648Z","@version":"1","message":"ENGINE-08024 Found processes.xml file at file:/camunda/webapps/camunda-invoice/WEB-INF/classes/META-INF/processes.xml","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.839898149Z","@version":"1","message":"ENGINE-07021 ProcessApplication 'InvoiceProcessApplication' registered for DB deployments [3ce17943-afa8-11ee-94d8-0242ac110003]. Will execute process definitions \n\n        invoice[version: 1, id: invoice:1:3cf06d67-afa8-11ee-94d8-0242ac110003]\n        ReviewInvoice[version: 1, id: ReviewInvoice:1:3cf157c9-afa8-11ee-94d8-0242ac110003]\nDeployment does not provide any case definitions.","logger_name":"org.camunda.bpm.application","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.849219186Z","@version":"1","message":"ENGINE-08023 Deployment summary for process archive 'InvoiceProcessApplication': \n\n        invoiceBusinessDecisions.dmn\n        invoice.v2.bpmn\n","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.921730763Z","@version":"1","message":"ENGINE-07021 ProcessApplication 'InvoiceProcessApplication' registered for DB deployments [3d0c32cd-afa8-11ee-94d8-0242ac110003, 3ce17943-afa8-11ee-94d8-0242ac110003]. Will execute process definitions \n\n        invoice[version: 2, id: invoice:2:3d0fb540-afa8-11ee-94d8-0242ac110003]\n        ReviewInvoice[version: 1, id: ReviewInvoice:1:3cf157c9-afa8-11ee-94d8-0242ac110003]\n        invoice[version: 1, id: invoice:1:3cf06d67-afa8-11ee-94d8-0242ac110003]\nDeployment does not provide any case definitions.","logger_name":"org.camunda.bpm.application","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.931264678Z","@version":"1","message":"SPIN-01010 Discovered Spin data format provider: org.camunda.spin.impl.json.jackson.format.JacksonJsonDataFormatProvider[name = application/json]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.932567176Z","@version":"1","message":"SPIN-01010 Discovered Spin data format provider: org.camunda.spin.impl.xml.dom.format.DomXmlDataFormatProvider[name = application/xml]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.943782045Z","@version":"1","message":"SPIN-01009 Discovered Spin data format: org.camunda.spin.impl.xml.dom.format.DomXmlDataFormat[name = application/xml]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.943980632Z","@version":"1","message":"SPIN-01009 Discovered Spin data format: org.camunda.spin.impl.json.jackson.format.JacksonJsonDataFormat[name = application/json]","logger_name":"org.camunda.spin","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:00.954494294Z","@version":"1","message":"Generating demo data for invoice showcase","logger_name":"org.camunda.bpm.example.invoice.DemoDataGenerator","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:01.286485313Z","@version":"1","message":"Start 3 instances of Invoice Receipt, version 1","logger_name":"org.camunda.bpm.example.invoice.InvoiceApplicationHelper","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:02.594947305Z","@version":"1","message":"\n\n  ... Now notifying creditor Bobby's Office Supplies\n\n","logger_name":"org.camunda.bpm.example.invoice.service.NotifyCreditorService","thread_name":"main","level":"INFO","level_value":20000,"activityId":"ServiceTask_06mdb3v","processDefinitionId":"invoice:1:3cf06d67-afa8-11ee-94d8-0242ac110003","processInstanceId":"3df2c1ba-afa8-11ee-94d8-0242ac110003","activityName":"Notify Creditor","engineName":"default","applicationName":"InvoiceProcessApplication"}
{"@timestamp":"2024-01-10T11:06:02.774576952Z","@version":"1","message":"Start 3 instances of Invoice Receipt, version 2","logger_name":"org.camunda.bpm.example.invoice.InvoiceApplicationHelper","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:03.066509833Z","@version":"1","message":"ENGINE-08050 Process application InvoiceProcessApplication successfully deployed","logger_name":"org.camunda.bpm.container","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:03.068786123Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/camunda-invoice] has finished in [3,620] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:03.069134987Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/manager]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:04.38243122Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:04.384137285Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/manager] has finished in [1,314] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:04.384331835Z","@version":"1","message":"Deploying web application directory [/camunda/webapps/camunda]","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:05.724867312Z","@version":"1","message":"At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.","logger_name":"org.apache.jasper.servlet.TldScanner","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:05.924257768Z","@version":"1","message":"Deployment of web application directory [/camunda/webapps/camunda] has finished in [1,540] ms","logger_name":"org.apache.catalina.startup.HostConfig","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:05.926460468Z","@version":"1","message":"Starting ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:05.937370701Z","@version":"1","message":"Server startup in [18066] milliseconds","logger_name":"org.apache.catalina.startup.Catalina","thread_name":"main","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.384292673Z","@version":"1","message":"ENGINE-14015 Shutting down the JobExecutor[org.camunda.bpm.engine.impl.jobexecutor.RuntimeContainerJobExecutor]","logger_name":"org.camunda.bpm.engine.jobexecutor","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.384664751Z","@version":"1","message":"ENGINE-14020 JobExecutor[org.camunda.bpm.engine.impl.jobexecutor.RuntimeContainerJobExecutor] stopped job acquisition","logger_name":"org.camunda.bpm.engine.jobexecutor","thread_name":"Thread-3","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.40211791Z","@version":"1","message":"ENGINE-08051 Process application InvoiceProcessApplication undeployed","logger_name":"org.camunda.bpm.container","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.404232763Z","@version":"1","message":"ENGINE-00007 Process Engine default closed","logger_name":"org.camunda.bpm.engine","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.404432473Z","@version":"1","message":"ENGINE-08049 Camunda Platform stopped at 'Apache Tomcat/9.0.75'","logger_name":"org.camunda.bpm.container","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.404830079Z","@version":"1","message":"Pausing ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.407283526Z","@version":"1","message":"Stopping service [Catalina]","logger_name":"org.apache.catalina.core.StandardService","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.416572757Z","@version":"1","message":"SessionListener: contextDestroyed()","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.41674764Z","@version":"1","message":"ContextListener: contextDestroyed()","logger_name":"org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/examples]","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.418391357Z","@version":"1","message":"ENGINE-07017 Calling undeploy() on process application that is not deployed.","logger_name":"org.camunda.bpm.application","thread_name":"Thread-6","level":"WARN","level_value":30000}
{"@timestamp":"2024-01-10T11:06:24.42710359Z","@version":"1","message":"Stopping ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"Thread-6","level":"INFO","level_value":20000}
{"@timestamp":"2024-01-10T11:06:24.430133473Z","@version":"1","message":"Destroying ProtocolHandler [\"http-nio-8080\"]","logger_name":"org.apache.coyote.http11.Http11NioProtocol","thread_name":"Thread-6","level":"INFO","level_value":20000}
```