package com.smartocr.document;

import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class DocumentService {
    private final DocumentRepository repository;

    public DocumentService(DocumentRepository repository) {
        this.repository = repository;
    }

    public DocumentResponse create(String ownerId, DocumentRequest request) {
        DocumentEntity entity = new DocumentEntity(ownerId, request.title(), request.documentType(),
                request.extractedText());
        if (request.status() == DocumentStatus.CONFIRMED) {
            entity.update(request.title(), request.documentType(), request.extractedText(), DocumentStatus.CONFIRMED);
        }
        return DocumentResponse.from(repository.save(entity));
    }

    @Transactional(readOnly = true)
    public List<DocumentResponse> list(String ownerId) {
        return repository.findAllByOwnerIdOrderByUpdatedAtDesc(ownerId).stream()
                .map(DocumentResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public DocumentResponse get(String ownerId, UUID id) {
        return DocumentResponse.from(findOwned(ownerId, id));
    }

    public DocumentResponse update(String ownerId, UUID id, DocumentRequest request) {
        DocumentEntity entity = findOwned(ownerId, id);
        entity.update(request.title(), request.documentType(), request.extractedText(),
                request.status() == null ? DocumentStatus.REVIEW_REQUIRED : request.status());
        return DocumentResponse.from(repository.save(entity));
    }

    public void delete(String ownerId, UUID id) {
        repository.delete(findOwned(ownerId, id));
    }

    private DocumentEntity findOwned(String ownerId, UUID id) {
        return repository.findByIdAndOwnerId(id, ownerId).orElseThrow(() -> new DocumentNotFoundException(id));
    }
}