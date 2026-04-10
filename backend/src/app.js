const express = require("express");
const cors = require("cors");
const path = require("path");
const pdfRoutes = require("./routes/pdfRoutes");
const { notFoundHandler, errorHandler } = require("./middleware/errorHandler");

const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN || "*" }));
app.use(express.json({ limit: "5mb" }));

app.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok" });
});

app.use("/downloads", express.static(path.join(__dirname, "../temp/outputs")));
app.use("/api/pdf", pdfRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
