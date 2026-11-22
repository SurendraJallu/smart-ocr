# Smart OCR — Initial Architecture

## High-level components

1. **Flutter client (Android/iOS):** camera and gallery import, document preview, crop/rotate, OCR review, and document history UI.
2. **On-device OCR:** ML Kit English text recognition for an offline-first initial experience.
3. **Spring Boot API:** authenticated document metadata, processing orchestration, and user-scoped history.
4. **PostgreSQL:** application metadata and extracted fields; avoid storing raw document images in database rows.
5. **Firebase Authentication:** user identity. The backend must verify Firebase ID tokens; client-side identity alone is not trusted.
6. **Firebase Storage:** private document object storage with user-scoped access rules.

## Initial data flow

1. User captures or imports a document.
2. App preprocesses the image and runs on-device OCR.
3. App presents recognized text and extracted fields for user review.
4. With user consent, the app uploads the document and saves metadata/extraction results through the API.
5. API verifies the Firebase ID token and enforces ownership for every document operation.

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
2. Flutter navigation, capture/import, and preview.
3. OCR integration and review/edit flow.
4. Spring Boot API, token verification, and PostgreSQL persistence.
5. Private storage and document history.
6. Document-specific extraction, exports, testing, and release hardening.

## Deployment note

iOS builds and App Store signing require macOS with Xcode and valid Apple developer signing configuration. Android release signing also requires user-managed signing credentials; these must never be committed.
