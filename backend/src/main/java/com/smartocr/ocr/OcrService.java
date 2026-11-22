package com.smartocr.ocr;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class OcrService {
    private static final long MAX_IMAGE_BYTES = 10L * 1024 * 1024;
    private static final long PROCESS_TIMEOUT_SECONDS = 60;

    private final String tesseractCommand;

    public OcrService(@Value("${smart-ocr.ocr.tesseract-command:tesseract}") String tesseractCommand) {
        this.tesseractCommand = tesseractCommand;
    }

    public OcrRecognitionResponse recognizeEnglish(MultipartFile image) {
        if (image == null || image.isEmpty()) {
            throw new IllegalArgumentException("An image file is required.");
        }
        if (image.getSize() > MAX_IMAGE_BYTES) {
            throw new IllegalArgumentException("Image must be 10 MB or smaller.");
        }

        String contentType = image.getContentType() == null ? "" : image.getContentType().toLowerCase(Locale.ROOT);
        String extension = switch (contentType) {
            case "image/jpeg", "image/jpg" -> ".jpg";
            case "image/png" -> ".png";
            case "image/tiff" -> ".tif";
            case "image/bmp" -> ".bmp";
            default -> throw new IllegalArgumentException("Supported image formats are JPEG, PNG, TIFF and BMP.");
        };

        Path input = null;
        Path errors = null;
        Path output = null;
        Process process = null;
        try {
            input = Files.createTempFile("smart-ocr-upload-", extension);
            errors = Files.createTempFile("smart-ocr-errors-", ".log");
            output = Files.createTempFile("smart-ocr-output-", ".txt");
            image.transferTo(input);
            process = new ProcessBuilder(tesseractCommand, input.toString(), "stdout", "-l", "eng", "--psm", "3")
                    .redirectError(errors.toFile())
                    .redirectOutput(output.toFile())
                    .start();

            boolean completed = process.waitFor(PROCESS_TIMEOUT_SECONDS, TimeUnit.SECONDS);
            if (!completed) {
                process.destroyForcibly();
                throw new OcrProcessingException("OCR processing timed out. Please try a smaller or clearer image.");
            }
            if (process.exitValue() != 0) {
                throw new OcrProcessingException("The server OCR engine could not process this image. Check server OCR setup.");
            }

            String text = Files.readString(output, java.nio.charset.StandardCharsets.UTF_8).strip();
            if (text.length() > 100_000) {
                text = text.substring(0, 100_000);
            }
            return new OcrRecognitionResponse(text, "eng", "Tesseract");
        } catch (IOException exception) {
            throw new OcrProcessingException(
                    "The server OCR engine is unavailable. Install Tesseract OCR and verify its executable path.", exception);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new OcrProcessingException("OCR processing was interrupted.", exception);
        } finally {
            if (process != null && process.isAlive()) {
                process.destroyForcibly();
            }
            deleteQuietly(input);
            deleteQuietly(errors);
            deleteQuietly(output);
        }
    }

    private void deleteQuietly(Path path) {
        if (path == null) return;
        try {
            Files.deleteIfExists(path);
        } catch (IOException ignored) {
            // Temporary OCR uploads are best-effort deleted; never log document content.
        }
    }
}
