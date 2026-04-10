const fs = require("fs");
const path = require("path");
const archiver = require("archiver");
const { PDFDocument, degrees } = require("pdf-lib");
const Poppler = require("pdf-poppler");
const { makeOutputPath } = require("../utils/fileUtils");

async function mergePdfs(inputPaths = []) {
  const mergedPdf = await PDFDocument.create();

  for (const filePath of inputPaths) {
    const bytes = await fs.promises.readFile(filePath);
    const sourcePdf = await PDFDocument.load(bytes);
    const pageIndices = sourcePdf.getPageIndices();
    const copiedPages = await mergedPdf.copyPages(sourcePdf, pageIndices);
    copiedPages.forEach((page) => mergedPdf.addPage(page));
  }

  const outputPath = makeOutputPath(".pdf");
  const outputBytes = await mergedPdf.save();
  await fs.promises.writeFile(outputPath, outputBytes);
  return outputPath;
}

async function splitPdf(inputPath) {
  const sourceBytes = await fs.promises.readFile(inputPath);
  const sourcePdf = await PDFDocument.load(sourceBytes);

  const splitOutputPaths = [];

  for (let i = 0; i < sourcePdf.getPageCount(); i += 1) {
    const singlePagePdf = await PDFDocument.create();
    const [page] = await singlePagePdf.copyPages(sourcePdf, [i]);
    singlePagePdf.addPage(page);
    const outputPath = makeOutputPath(".pdf");
    const outputBytes = await singlePagePdf.save();
    await fs.promises.writeFile(outputPath, outputBytes);
    splitOutputPaths.push(outputPath);
  }

  return splitOutputPaths;
}

async function imagesToPdf(imagePaths = []) {
  const pdf = await PDFDocument.create();

  for (const imagePath of imagePaths) {
    const imageBytes = await fs.promises.readFile(imagePath);
    const ext = path.extname(imagePath).toLowerCase();
    let embedded;

    if (ext === ".png") {
      embedded = await pdf.embedPng(imageBytes);
    } else {
      embedded = await pdf.embedJpg(imageBytes);
    }

    const page = pdf.addPage([embedded.width, embedded.height]);
    page.drawImage(embedded, {
      x: 0,
      y: 0,
      width: embedded.width,
      height: embedded.height,
    });
  }

  const outputPath = makeOutputPath(".pdf");
  const outputBytes = await pdf.save();
  await fs.promises.writeFile(outputPath, outputBytes);
  return outputPath;
}

async function rotatePdf(inputPath, angle = 90) {
  const sourceBytes = await fs.promises.readFile(inputPath);
  const pdf = await PDFDocument.load(sourceBytes);

  pdf.getPages().forEach((page) => {
    page.setRotation(degrees(angle));
  });

  const outputPath = makeOutputPath(".pdf");
  const outputBytes = await pdf.save();
  await fs.promises.writeFile(outputPath, outputBytes);
  return outputPath;
}

async function pdfToImages(inputPath) {
  const outputPrefix = path.basename(makeOutputPath(""));
  const convertOptions = {
    format: "png",
    out_dir: path.join(__dirname, "../../temp/outputs"),
    out_prefix: outputPrefix,
    page: null,
  };

  await Poppler.convert(inputPath, convertOptions);

  const files = await fs.promises.readdir(path.join(__dirname, "../../temp/outputs"));
  const generatedPaths = files
    .filter((name) => name.startsWith(outputPrefix) && name.endsWith(".png"))
    .map((name) => path.join(__dirname, "../../temp/outputs", name));

  return generatedPaths;
}

async function zipFiles(filePaths, outputExtension = ".zip") {
  const zipPath = makeOutputPath(outputExtension);

  await new Promise((resolve, reject) => {
    const outputStream = fs.createWriteStream(zipPath);
    const archive = archiver("zip", { zlib: { level: 9 } });

    outputStream.on("close", resolve);
    outputStream.on("error", reject);
    archive.on("error", reject);

    archive.pipe(outputStream);

    filePaths.forEach((filePath) => {
      archive.file(filePath, { name: path.basename(filePath) });
    });

    archive.finalize();
  });

  return zipPath;
}

module.exports = {
  mergePdfs,
  splitPdf,
  imagesToPdf,
  rotatePdf,
  pdfToImages,
  zipFiles,
};
