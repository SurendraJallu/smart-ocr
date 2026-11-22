package com.smartocr.document;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DocumentRepository extends JpaRepository<DocumentEntity, UUID> {
    List<DocumentEntity> findAllByOwnerIdOrderByUpdatedAtDesc(String ownerId);
    Optional<DocumentEntity> findByIdAndOwnerId(UUID id, String ownerId);
}