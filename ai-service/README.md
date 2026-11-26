# Smart OCR AI Service

Local Python OCR service for the Smart OCR application. This service is separate from the existing Java Spring Boot API.

## Requirements

- Python 3.11 (recommended)
- CPU is sufficient for the initial development milestone
- Internet access on first OCR run so PaddleOCR can download its pretrained model files

## Setup (Windows PowerShell)

From the repository root:

```powershell
cd ai-service
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

PaddlePaddle CPU installation instructions can vary by Python version and platform. If the `paddlepaddle==3.2.0` installation fails, use the official CPU installation selector at https://www.paddlepaddle.org.cn/install/quick and keep the PaddlePaddle version compatible with PaddleOCR 3.x.

## Run

```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

Health check: `http://localhost:8001/health`

Interactive API documentation: `http://localhost:8001/docs`

## OCR endpoint

`POST /api/v1/ocr/recognize`

Send one image as multipart form data using the field name `image`. The service validates the image and enforces a 10 MB upload limit. PaddleOCR is initialized lazily on the first OCR request; the first request can take longer while pretrained models are downloaded and loaded.

The response contains extracted text and line-level confidence scores and bounding boxes. This is the initial OCR foundation; document classification, table/layout parsing, and hosted vision-model integration will be added in later milestones.

## Configuration

- `MAX_UPLOAD_BYTES`: maximum accepted upload size (default `10485760`)
- `LOG_LEVEL`: Python logging level (default `INFO`)

Do not commit uploaded documents, model files, credentials, or `.env` files.
