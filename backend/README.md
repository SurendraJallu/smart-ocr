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

## Server-side OCR API

The authenticated mobile client uploads an image to the server for centralized English OCR. The backend invokes the Tesseract command-line engine and returns recognized text; it does not persist the uploaded image. Temporary upload, output and error files are deleted after processing.

Install Tesseract on the backend host and ensure the executable is available on PATH:

- Ubuntu/Debian: `sudo apt-get update && sudo apt-get install -y tesseract-ocr tesseract-ocr-eng`
- Verify: `tesseract --version` and `tesseract --list-langs`

If the executable is not named `tesseract` or is outside PATH, set `SMART_OCR_OCR_TESSERACT_COMMAND`? The Spring property is `smart-ocr.ocr.tesseract-command`; configure it with `SMART_OCR_OCR_TESSERACT_COMMAND` only if your deployment maps that environment variable, or override the property directly.

Endpoint:

- `POST /api/v1/ocr/recognize` — authenticated multipart request with image field named `image`; supports JPEG, PNG, TIFF and BMP up to 10 MB. Returns `text`, `language` and `engine`.

Example:

```bash
curl -X POST http://localhost:8080/api/v1/ocr/recognize \
  -H "Authorization: Bearer <firebase-id-token>" \
  -F "image=@./sample-document.jpg"
```

The OCR endpoint is authenticated and processes images temporarily on the server. Use HTTPS in deployed environments. Add malware scanning, request throttling, isolated OCR workers and production observability before exposing it publicly.

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
  "extractedText": "Text recognized by server-side OCR",
  "status": "REVIEW_REQUIRED"
}
```

OCR output is untrusted and must be reviewed by the user. The document API stores extracted text and metadata only. Original images are currently processed temporarily for OCR and are not retained. Binary image storage, retention workflows, audit logging, and production monitoring remain follow-on release tasks. Do not send real identity or medical documents to an unconfigured development environment.
