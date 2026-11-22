package com.smartocr.document;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "documents")
public class DocumentEntity {

    @Id
    private UUID id;

    @Column(name = "owner_id", nullable = false, length = 128)
    private String ownerId;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(name = "document_type", nullable = false, length = 40)
    private String documentType;

    @Column(name = "extracted_text", nullable = false, columnDefinition = "text")
    private String extractedText;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private DocumentStatus status;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected DocumentEntity() { }

    public DocumentEntity(String ownerId, String title, String documentType, String extractedText) {
        this.ownerId = ownerId;
        this.title = title;
        this.documentType = documentType;
        this.extractedText = extractedText;
        this.status = DocumentStatus.REVIEW_REQUIRED;
    }

    @PrePersist
    void onCreate() {
        id = UUID.randomUUID();
        createdAt = Instant.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public String getOwnerId() { return ownerId; }
    public String getTitle() { return title; }
    public String getDocumentType() { return documentType; }
    public String getExtractedText() { return extractedText; }
    public DocumentStatus getStatus() { return status; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }

    public void update(String title, String documentType, String extractedText, DocumentStatus status) {
        this.title = title;
        this.documentType = documentType;
        this.extractedText = extractedText;
        this.status = status;
    }
}