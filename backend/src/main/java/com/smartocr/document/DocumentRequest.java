package com.smartocr.document;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record DocumentRequest(
        @NotBlank @Size(max = 160) String title,
        @NotBlank @Size(max = 40) String documentType,
        @NotBlank @Size(max = 100000) String extractedText,
        DocumentStatus status) { }