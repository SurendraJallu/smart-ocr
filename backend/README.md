# Backend API

This directory contains the Java Spring Boot REST API.

## Standardized build baseline

- Java 25 (LTS)
- Spring Boot 3.5.16
- Maven
- Spring Web and Bean Validation
- Spring Security with Firebase ID-token verification
- Spring Data JPA
- PostgreSQL
- Flyway database migrations
- Actuator health endpoints

Use a Java 25 distribution such as Eclipse Temurin 25 for local development and CI. Ensure Maven itself runs on JDK 25; check both java -version and mvn -version.

## Responsibilities

- Verify Firebase ID tokens on protected endpoints.
- Enforce user ownership for all document records and operations.
- Persist document metadata and user-confirmed extracted fields.
- Coordinate private object storage access.
- Provide paginated document history and export metadata.

## Local configuration

Use environment variables for database credentials and Firebase verification configuration. Never commit secrets or production service-account keys.

Run backend tests from this directory:

    mvn clean verify
