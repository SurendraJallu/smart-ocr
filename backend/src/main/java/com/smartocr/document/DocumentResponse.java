package com.smartocr.document;

import java.time.Instant;
import java.util.UUID;

public record DocumentResponse(
        UUID id, String title, String documentType, String extractedText,
        DocumentStatus status, Instant createdAt, Instant updatedAt) {
    static DocumentResponse from(DocumentEntity entity) {
        return new DocumentResponse(entity.getId(), entity.getTitle(), entity.getDocumentType(),
                entity.getExtractedText(), entity.getStatus(), entity.getCreatedAt(), entity.getUpdatedAt());
    }
}