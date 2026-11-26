import json
import logging
import os
import tempfile
from pathlib import Path
from threading import Lock
from typing import Any

from fastapi import FastAPI, File, HTTPException, UploadFile
from PIL import Image, UnidentifiedImageError
from starlette.concurrency import run_in_threadpool

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger("smart-ocr-ai")

APP_NAME = "smart-ocr-ai-service"
MAX_UPLOAD_BYTES = int(os.getenv("MAX_UPLOAD_BYTES", str(10 * 1024 * 1024)))
ALLOWED_FORMATS = {"JPEG", "PNG", "WEBP", "TIFF", "BMP"}

app = FastAPI(title=APP_NAME, version="0.1.0")
_ocr_instance: Any | None = None
_ocr_lock = Lock()


def get_ocr() -> Any:
    """Create the OCR pipeline once, on the first OCR request."""
    global _ocr_instance

    if _ocr_instance is None:
        with _ocr_lock:
            if _ocr_instance is None:
                from paddleocr import PaddleOCR

                logger.info("Loading PaddleOCR models (first request may take time)")
                _ocr_instance = PaddleOCR(
                    use_doc_orientation_classify=False,
                    use_doc_unwarping=False,
                    use_textline_orientation=False,
                    engine="paddle",
                )
                logger.info("PaddleOCR models loaded")

    return _ocr_instance


def to_json_value(value: Any) -> Any:
    """Convert NumPy values and other PaddleOCR output values to JSON-safe data."""
    if hasattr(value, "tolist"):
        return value.tolist()
    if isinstance(value, dict):
        return {str(key): to_json_value(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [to_json_value(item) for item in value]
    if hasattr(value, "item"):
        return value.item()
    return value


def extract_lines(result: Any) -> list[dict[str, Any]]:
    raw = getattr(result, "json", None)
    if callable(raw):
        raw = raw()
    if isinstance(raw, str):
        raw = json.loads(raw)
    if not isinstance(raw, dict):
        try:
            raw = dict(result)
        except (TypeError, ValueError):
            raw = {}

    data = raw.get("res", raw)
    texts = data.get("rec_texts", []) or []
    scores = data.get("rec_scores", []) or []
    boxes = data.get("rec_boxes", []) or []

    lines: list[dict[str, Any]] = []
    for index, text in enumerate(texts):
        score = scores[index] if index < len(scores) else None
        box = boxes[index] if index < len(boxes) else None
        lines.append(
            {
                "text": str(text),
                "confidence": float(score) if score is not None else None,
                "boundingBox": to_json_value(box) if box is not None else None,
            }
        )
    return lines


def run_ocr(image_path: str) -> dict[str, Any]:
    engine = get_ocr()
    results = engine.predict(image_path)
    lines: list[dict[str, Any]] = []
    for result in results:
        lines.extend(extract_lines(result))

    return {
        "engine": "PaddleOCR",
        "text": "\n".join(line["text"] for line in lines),
        "lines": lines,
    }


@app.get("/health")
def health() -> dict[str, Any]:
    return {
        "service": APP_NAME,
        "status": "UP",
        "ocrModelLoaded": _ocr_instance is not None,
    }


@app.post("/api/v1/ocr/recognize")
async def recognize(image: UploadFile = File(...)) -> dict[str, Any]:
    suffix = Path(image.filename or "").suffix.lower()
    temp_path: str | None = None

    try:
        contents = await image.read(MAX_UPLOAD_BYTES + 1)
        if not contents:
            raise HTTPException(status_code=400, detail="The uploaded image is empty.")
        if len(contents) > MAX_UPLOAD_BYTES:
            raise HTTPException(status_code=413, detail="Image exceeds the upload size limit.")

        try:
            from io import BytesIO

            with Image.open(BytesIO(contents)) as uploaded_image:
                image_format = (uploaded_image.format or "").upper()
                uploaded_image.verify()
        except (UnidentifiedImageError, OSError):
            raise HTTPException(status_code=415, detail="Upload a valid image file.")

        if image_format not in ALLOWED_FORMATS:
            raise HTTPException(status_code=415, detail="This image format is not supported.")

        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix or ".img") as temp_file:
            temp_file.write(contents)
            temp_path = temp_file.name

        return await run_in_threadpool(run_ocr, temp_path)

    except HTTPException:
        raise
    except Exception:
        logger.exception("OCR processing failed")
        raise HTTPException(status_code=500, detail="OCR processing failed.")
    finally:
        await image.close()
        if temp_path:
            Path(temp_path).unlink(missing_ok=True)
