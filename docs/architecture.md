# Smart OCR — Initial Architecture

## High-level components

1. **Flutter client (Android/iOS):** camera and gallery import, document preview, crop/rotate, OCR review, and document history UI.
2. **Server OCR engine:** Tesseract English recognition runs on the backend. The Flutter client uploads images through an authenticated multipart REST endpoint; optional on-device OCR may be added later as an offline capability.
3. **Spring Boot API:** authenticated document metadata, processing orchestration, and user-scoped history. Backend baseline: Java 25 LTS and Spring Boot 3.5.16.
4. **PostgreSQL:** application metadata and extracted fields; avoid storing raw document images in database rows.
5. **Firebase Authentication:** user identity. The backend must verify Firebase ID tokens; client-side identity alone is not trusted.
6. **Firebase Storage:** private document object storage with user-scoped access rules.

## Initial data flow

1. User captures or imports a document.
2. App uploads the image to the authenticated OCR endpoint over HTTPS.
3. API verifies the Firebase ID token, validates the image, applies upload/time limits, and invokes Tesseract on a temporary server-side file.
4. OCR text is returned to the app for user review; temporary image and engine output files are deleted after processing.
5. User confirms the text and the app saves extracted text and metadata through the authenticated document API.

## Document categories

Aadhaar, PAN, marksheets, vehicle registration certificates (RC), medical prescriptions, and generic documents.

Classification and extracted values are suggestions only. The user must review and confirm them. OCR output must never be represented as authoritative verification.

## Security baseline

- Collect and retain only data required for the requested feature.
- Enforce authentication and per-user authorization on every API operation.
- Keep storage buckets private; use short-lived access where appropriate.
- Never log OCR text, document images, identity numbers, medical details, tokens, or secrets.
- Encrypt data in transit and at rest; define retention and deletion behavior before production.
- Add audit events for sensitive access and changes.
- Add rate limits, backups, monitoring, dependency scanning, and security tests before release.

## Delivery sequence

1. Repository and build foundations.
2. Flutter capture/import, preview, authentication, and API client.
3. Spring Boot API, token verification, PostgreSQL persistence, and server-side OCR.
5. Private storage and document history.
6. Document-specific extraction, exports, testing, and release hardening.

## Deployment note

Use JDK 25 for local backend development, automated builds, and deployment runtime. iOS builds and App Store signing require macOS with Xcode and valid Apple developer signing configuration. Android release signing also requires user-managed signing credentials; these must never be committed.
