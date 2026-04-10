const path = require("path");
const fs = require("fs");
const {
  mergePdfs,
  splitPdf,
  imagesToPdf,
  rotatePdf,
  pdfToImages,
  zipFiles,
} = require("../services/pdfService");
const { removeFiles } = require("../utils/fileUtils");

function buildPublicFileInfo(req, filePath) {
  const fileName = path.basename(filePath);
  const baseUrl = `${req.protocol}://${req.get("host")}`;

  return {
    fileName,
    downloadUrl: `${baseUrl}/downloads/${fileName}`,
  };
}

function ensureFiles(files, minCount = 1) {
  if (!files || files.length < minCount) {
    const error = new Error(`Please upload at least ${minCount} file(s).`);
    error.statusCode = 400;
    throw error;
  }
}

async function isPdfBySignature(filePath) {
  if (!filePath) {
    return false;
  }

  try {
    const handle = await fs.promises.open(filePath, "r");
    try {
      const headerBuffer = Buffer.alloc(5);
      await handle.read(headerBuffer, 0, 5, 0);
      return headerBuffer.toString("utf8") === "%PDF-";
    } finally {
      await handle.close();
    }
  } catch (_error) {
    return false;
  }
}

async function ensurePdfFiles(files) {
  const allowedMimes = new Set([
    "application/pdf",
    "application/x-pdf",
    "application/acrobat",
    "application/vnd.pdf",
    "text/pdf",
  ]);

  let invalid;

  for (const file of files || []) {
    const name = file.originalname?.toLowerCase() || "";
    const mime = file.mimetype?.toLowerCase() || "";
    const hasPdfExtension = name.endsWith(".pdf");
    const hasPdfMime = allowedMimes.has(mime);
    const hasPdfSignature = await isPdfBySignature(file.path);

    if (!hasPdfExtension && !hasPdfMime && !hasPdfSignature) {
      invalid = file;
      break;
    }
  }

  if (invalid) {
    const error = new Error("Only PDF files are allowed for this operation.");
    error.statusCode = 400;
    throw error;
  }
}

function ensureImageFiles(files) {
  const validExtensions = [".jpg", ".jpeg", ".png"];
  const validMimes = ["image/jpeg", "image/png"];

  const invalid = (files || []).find((file) => {
    const name = file.originalname?.toLowerCase() || "";
    const mime = file.mimetype?.toLowerCase() || "";
    const hasValidExtension = validExtensions.some((ext) => name.endsWith(ext));
    return !hasValidExtension && !validMimes.includes(mime);
  });

  if (invalid) {
    const error = new Error("Only JPG, JPEG, or PNG images are allowed.");
    error.statusCode = 400;
    throw error;
  }
}

async function merge(req, res, next) {
  const uploadedPaths = (req.files || []).map((f) => f.path);

  try {
    ensureFiles(req.files, 2);
    await ensurePdfFiles(req.files);
    const outputPath = await mergePdfs(uploadedPaths);
    res.status(200).json({ message: "PDFs merged successfully", ...buildPublicFileInfo(req, outputPath) });
  } catch (error) {
    next(error);
  } finally {
    await removeFiles(uploadedPaths);
  }
}

async function split(req, res, next) {
  const uploadedPath = req.file?.path;

  try {
    ensureFiles(uploadedPath ? [req.file] : [], 1);
    await ensurePdfFiles(uploadedPath ? [req.file] : []);
    const pagePdfs = await splitPdf(uploadedPath);
    const zipPath = await zipFiles(pagePdfs);
    await removeFiles(pagePdfs);
    res.status(200).json({ message: "PDF split successfully", ...buildPublicFileInfo(req, zipPath) });
  } catch (error) {
    next(error);
  } finally {
    await removeFiles([uploadedPath]);
  }
}

async function imagesToPdfController(req, res, next) {
  const uploadedPaths = (req.files || []).map((f) => f.path);

  try {
    ensureFiles(req.files, 1);
    ensureImageFiles(req.files);
    const outputPath = await imagesToPdf(uploadedPaths);
    res
      .status(200)
      .json({ message: "Images converted to PDF successfully", ...buildPublicFileInfo(req, outputPath) });
  } catch (error) {
    next(error);
  } finally {
    await removeFiles(uploadedPaths);
  }
}

async function pdfToImagesController(req, res, next) {
  const uploadedPath = req.file?.path;

  try {
    ensureFiles(uploadedPath ? [req.file] : [], 1);
    await ensurePdfFiles(uploadedPath ? [req.file] : []);
    const imagePaths = await pdfToImages(uploadedPath);
    const zipPath = await zipFiles(imagePaths);
    await removeFiles(imagePaths);
    res.status(200).json({ message: "PDF converted to images successfully", ...buildPublicFileInfo(req, zipPath) });
  } catch (error) {
    next(error);
  } finally {
    await removeFiles([uploadedPath]);
  }
}

async function rotate(req, res, next) {
  const uploadedPath = req.file?.path;

  try {
    ensureFiles(uploadedPath ? [req.file] : [], 1);
    await ensurePdfFiles(uploadedPath ? [req.file] : []);
    const requestedAngle = Number.parseInt(req.body.angle, 10);
    const angle = Number.isNaN(requestedAngle) ? 90 : requestedAngle;

    if (![90, 180, 270].includes(angle)) {
      const error = new Error("Rotation angle must be one of: 90, 180, 270.");
      error.statusCode = 400;
      throw error;
    }

    const outputPath = await rotatePdf(uploadedPath, angle);
    res.status(200).json({ message: "PDF rotated successfully", ...buildPublicFileInfo(req, outputPath) });
  } catch (error) {
    next(error);
  } finally {
    await removeFiles([uploadedPath]);
  }
}

module.exports = {
  merge,
  split,
  imagesToPdfController,
  pdfToImagesController,
  rotate,
};
