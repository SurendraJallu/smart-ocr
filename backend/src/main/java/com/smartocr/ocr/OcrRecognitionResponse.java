package com.smartocr.ocr;

public record OcrRecognitionResponse(String text, String language, String engine) { }
