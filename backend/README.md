# Smart OCR backend

Java 25 LTS, Spring Boot 3.5.16, PostgreSQL, Flyway and Spring Security OAuth2 Resource Server.

## Requirements

- JDK 25
- Maven 3.6.3+
- Docker Compose

## Start PostgreSQL

From the repository root:

```bash
docker compose -f infra/docker-compose.yml up -d
```

## Configure Firebase token verification

Set these environment variables to your Firebase project:

```bash
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_ISSUER_URI=https://securetoken.google.com/your-firebase-project-id
DATABASE_URL=jdbc:postgresql://localhost:5432/smart_ocr
DATABASE_USERNAME=smart_ocr
DATABASE_PASSWORD=your-local-database-password
```

The default `demo-smart-ocr` issuer is only a development placeholder. Configure your own Firebase project before calling authenticated endpoints. The API verifies token signature, issuer and audience. Never trust a client-supplied user ID.

## Run and test

```bash
mvn clean verify
mvn spring-boot:run
```

The API listens on port 8080. `GET /api/v1/health` is public; document endpoints require a valid Firebase ID token in `Authorization: Bearer <id-token>`.

## Document API

- `POST /api/v1/documents` — create a document record
- `GET /api/v1/documents` — list the signed-in user's documents
- `GET /api/v1/documents/{id}` — retrieve one owned document
- `PUT /api/v1/documents/{id}` — update reviewed OCR text and status
- `DELETE /api/v1/documents/{id}` — delete an owned record

Example request body:

```json
{
  "title": "Scanned document",
  "documentType": "GENERAL",
  "extractedText": "Text recognized by on-device OCR",
  "status": "REVIEW_REQUIRED"
}
```

OCR output is untrusted and must be reviewed by the user. This API stores extracted text and metadata only; binary image storage, retention workflows, audit logging, and production monitoring remain follow-on release tasks. Do not send real identity or medical documents to an unconfigured development environment.
