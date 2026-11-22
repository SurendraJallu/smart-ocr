package com.smartocr.ocr;

import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class OcrExceptionHandler {
    @ExceptionHandler(IllegalArgumentException.class)
    ResponseEntity<Map<String, String>> invalidImage(IllegalArgumentException exception) {
        return ResponseEntity.badRequest().body(Map.of("error", "INVALID_IMAGE", "message", exception.getMessage()));
    }

    @ExceptionHandler(OcrProcessingException.class)
    ResponseEntity<Map<String, String>> processingFailure(OcrProcessingException exception) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(Map.of("error", "OCR_UNAVAILABLE", "message", exception.getMessage()));
    }
}
