const fs = require("fs");
const path = require("path");
const { v4: uuidv4 } = require("uuid");

const outputsDir = path.join(__dirname, "../../temp/outputs");

function makeOutputPath(extension) {
  const safeExt = extension.startsWith(".") ? extension : `.${extension}`;
  return path.join(outputsDir, `${uuidv4()}${safeExt}`);
}

async function removeFiles(filePaths = []) {
  await Promise.all(
    filePaths
      .filter(Boolean)
      .map(async (filePath) => {
        try {
          await fs.promises.unlink(filePath);
        } catch (_error) {
          // Ignore cleanup failures.
        }
      })
  );
}

module.exports = {
  outputsDir,
  makeOutputPath,
  removeFiles,
};
