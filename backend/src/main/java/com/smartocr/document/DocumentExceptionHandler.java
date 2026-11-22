package com.smartocr.document;

import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class DocumentExceptionHandler {

    @ExceptionHandler(DocumentNotFoundException.class)
    ResponseEntity<Map<String, String>> notFound(DocumentNotFoundException exception) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "DOCUMENT_NOT_FOUND"));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<Map<String, String>> invalidRequest() {
        return ResponseEntity.badRequest().body(Map.of("error", "INVALID_REQUEST"));
    }
}