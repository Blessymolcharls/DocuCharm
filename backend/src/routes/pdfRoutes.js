const express = require("express");
const upload = require("../middleware/upload");
const {
  merge,
  split,
  imagesToPdfController,
  pdfToImagesController,
  rotate,
} = require("../controllers/pdfController");

const router = express.Router();

router.post("/merge", upload.array("files", 20), merge);
router.post("/split", upload.single("file"), split);
router.post("/images-to-pdf", upload.array("files", 20), imagesToPdfController);
router.post("/pdf-to-images", upload.single("file"), pdfToImagesController);
router.post("/rotate", upload.single("file"), rotate);

module.exports = router;
