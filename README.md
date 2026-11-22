# Smart OCR

Cross-platform document capture and OCR application for Android and iOS.

## Planned stack

- **Mobile:** Flutter (Dart)
- **Backend:** Java 25 (LTS) + Spring Boot 3.5.16
- **Database:** PostgreSQL
- **Authentication:** Firebase Authentication
- **File storage:** Firebase Storage
- **OCR:** Google ML Kit Text Recognition (English, on-device initially)
- **Image processing:** OpenCV (introduced when preprocessing requirements are implemented)

## Repository layout

    mobile/       Flutter application
    backend/      Spring Boot REST API
    infra/        Local development infrastructure
    docs/         Architecture and development documentation

## Getting started

The repository is currently being initialized. See:

- [Architecture](docs/architecture.md)
- [Mobile setup](mobile/README.md)
- [Backend setup](backend/README.md)
- [Local infrastructure](infra/README.md)

## Development workflow

- main: stable releases
- develop: integration branch
- features/*: isolated feature work, merged into develop through pull requests

Do not commit credentials, Firebase service-account files, signing keys, or real personal documents.
