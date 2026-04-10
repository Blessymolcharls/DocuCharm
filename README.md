# DocuCharm

DocuCharm is a modern mobile PDF toolkit inspired by iLovePDF.

- Frontend: Flutter mobile app
- Backend: Node.js + Express REST API
- PDF processing: pdf-lib (+ Poppler for PDF to images)

## Features Implemented

1. Merge multiple PDF files into one
2. Split a PDF into single-page PDFs (returned as ZIP)
3. Convert images to PDF
4. Convert PDF to images (returned as ZIP)
5. Rotate PDF pages (90/180/270)
6. View generated PDFs in app
7. Download + share processed output
8. Dark mode support
9. Animated, card-based modern UI
10. Error/success snack messages + loading/progress indicators
11. Drag-and-drop upload support (desktop) + file picker (mobile/desktop)

## Project Structure

```
DocuCharm/
  backend/
    src/
      controllers/
      middleware/
      routes/
      services/
      utils/
    temp/
      uploads/
      outputs/
  frontend/
    lib/
      core/
      features/
```

## Backend Setup (Node.js)

Prerequisites:
- Node.js 18+
- Poppler installed and available in PATH (required for PDF to images)

Install + run:

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

Server default URL:
- http://localhost:4000

Health check:
- GET /health

### REST API Endpoints

Base path: /api/pdf

- POST /merge
  - multipart field: files (2..20 PDFs)
- POST /split
  - multipart field: file (1 PDF)
- POST /images-to-pdf
  - multipart field: files (1..20 images: jpg/jpeg/png)
- POST /pdf-to-images
  - multipart field: file (1 PDF)
- POST /rotate
  - multipart field: file (1 PDF)
  - body field: angle (90 | 180 | 270)

Each successful response returns:

```json
{
  "message": "...",
  "fileName": "...",
  "downloadUrl": "http://localhost:4000/downloads/..."
}
```

## Flutter Setup

Prerequisites:
- Flutter SDK 3.22+
- Android Studio / Xcode (depending on target)

Install + run:

```bash
cd frontend
flutter pub get
flutter run
```

You can override the backend URL:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4000
```

Important local API note:
- Android emulator uses 10.0.2.2 for localhost mapping.
- Base URL is defined in: frontend/lib/core/constants/api_constants.dart

## Architecture

- Flutter app picks files and uploads them to backend using multipart HTTP.
- Express API receives files with multer.
- PDF processing is handled in backend service layer.
- Generated files are stored temporarily in backend/temp/outputs.
- API returns a download URL consumed by Flutter.

## Optional Advanced Features (Planned Extension Points)

You can add these next:
- PDF compression endpoint and UI flow
- Watermark/text stamping using pdf-lib drawText or drawImage
- AI-based summarization using OCR + LLM service integration
- User login and file history persistence (JWT + DB)

## Notes

- PDF to images requires Poppler binaries installed on your system.
- Temporary file cleanup is included for uploaded intermediates.
- For production, add auth, rate limiting, virus scanning, and cloud object storage.
