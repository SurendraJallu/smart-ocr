package com.smartocr.ocr;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import javax.imageio.ImageIO;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;

class OcrServiceTest {
    private final OcrService service = new OcrService("tesseract");

    @Test
    void rejectsUnsupportedImageTypes() {
        var image = new MockMultipartFile("image", "notes.txt", "text/plain", "not an image".getBytes());
        assertThrows(IllegalArgumentException.class, () -> service.recognizeEnglish(image));
    }

    @Test
    void rejectsImagesLargerThanTenMegabytes() {
        var image = new MockMultipartFile("image", "large.png", "image/png", new byte[10 * 1024 * 1024 + 1]);
        assertThrows(IllegalArgumentException.class, () -> service.recognizeEnglish(image));
    }

    @Test
    void recognizesEnglishTextWhenTesseractIsInstalled() throws IOException {
        Assumptions.assumeTrue(isTesseractAvailable(), "Tesseract is not installed in this environment");
        BufferedImage canvas = new BufferedImage(1200, 220, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = canvas.createGraphics();
        try {
            graphics.setColor(Color.WHITE);
            graphics.fillRect(0, 0, canvas.getWidth(), canvas.getHeight());
            graphics.setColor(Color.BLACK);
            graphics.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 90));
            graphics.drawString("SMART OCR TEST", 35, 145);
        } finally {
            graphics.dispose();
        }
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        ImageIO.write(canvas, "png", bytes);
        var image = new MockMultipartFile("image", "sample.png", "image/png", bytes.toByteArray());

        OcrRecognitionResponse result = service.recognizeEnglish(image);

        assertTrue(result.text().toUpperCase().contains("SMART OCR"));
        assertTrue(result.text().toUpperCase().contains("TEST"));
        assertTrue(result.language().equals("eng"));
    }

    private boolean isTesseractAvailable() {
        try {
            return new ProcessBuilder("tesseract", "--version").start().waitFor() == 0;
        } catch (IOException exception) {
            return false;
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            return false;
        }
    }
}
