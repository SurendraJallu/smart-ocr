# Backend API

This directory is reserved for the Java Spring Boot REST API.

## Planned baseline

- Java 21
- Spring Boot 3.x
- Maven
- Spring Web and Bean Validation
- Spring Security with Firebase ID-token verification
- Spring Data JPA
- PostgreSQL
- Flyway database migrations
- Actuator health endpoints

## Responsibilities

- Verify Firebase ID tokens on protected endpoints.
- Enforce user ownership for all document records and operations.
- Persist document metadata and user-confirmed extracted fields.
- Coordinate private object storage access.
- Provide paginated document history and export metadata.

## Local configuration

Use environment variables for database credentials and Firebase verification configuration. Never commit secrets or production service-account keys.

The API contract and executable Spring Boot module will be added in the backend implementation step.
