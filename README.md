# Camunda BPM Platform JSON Logging Patterns

Patterns for enabling JSON logging on Camunda BPM Distributions.

By default, camunda logs using standard java logging, which means they are difficult to parse and import into other logging systems such as logstash, greylog, etc.  JSON is generally considered the interop standard for logs.

# Tomcat

Patterns for enabling JSON Logging on the Tomcat distribution of Camunda BPM Platform.

## Docker

| Version | Description |
| ------- | ----------- |
| [7.9.0](./tomcat/7.9.0/docker) | Docker base image for pulling into other projects or use as a `docker run` command.  Modifies Tomcat logging for usage with Logback, SLFJ4, and JSON logging using logstash-logback-encoder.
