CREATE TABLE documents (
    id UUID PRIMARY KEY,
    owner_id VARCHAR(128) NOT NULL,
    title VARCHAR(160) NOT NULL,
    document_type VARCHAR(40) NOT NULL,
    extracted_text TEXT NOT NULL,
    status VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_documents_owner_updated
    ON documents (owner_id, updated_at DESC);