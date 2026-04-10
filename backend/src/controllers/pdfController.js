const path = require("path");
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

function ensurePdfFiles(files) {
  const invalid = (files || []).find((file) => {
    const name = file.originalname?.toLowerCase() || "";
    const mime = file.mimetype?.toLowerCase() || "";
    return !name.endsWith(".pdf") && mime !== "application/pdf";
  });

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
    ensurePdfFiles(req.files);
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
    ensurePdfFiles(uploadedPath ? [req.file] : []);
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
    ensurePdfFiles(uploadedPath ? [req.file] : []);
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
    ensurePdfFiles(uploadedPath ? [req.file] : []);
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
