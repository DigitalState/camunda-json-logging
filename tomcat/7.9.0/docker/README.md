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


# Customize JSON format and content

The pattern uses the [Logstash-Logback-Encoder library v5.2](https://github.com/logstash/logstash-logback-encoder/tree/logstash-logback-encoder-5.2).  See the Readme of the library for further configuration options.