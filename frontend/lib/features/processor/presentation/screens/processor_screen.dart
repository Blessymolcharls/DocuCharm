import "dart:io";

import "package:docucharm_frontend/core/network/pdf_api_client.dart";
import "package:docucharm_frontend/features/processor/domain/tool_type.dart";
import "package:docucharm_frontend/features/viewer/presentation/pdf_viewer_screen.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:open_filex/open_filex.dart";
import "package:share_plus/share_plus.dart";

class ProcessorScreen extends StatefulWidget {
  const ProcessorScreen({super.key, required this.tool});

  final ToolType tool;

  @override
  State<ProcessorScreen> createState() => _ProcessorScreenState();
}

class _ProcessorScreenState extends State<ProcessorScreen> {
  final PdfApiClient _apiClient = PdfApiClient();
  final List<File> _selectedFiles = [];

  bool _isProcessing = false;
  bool _isDownloading = false;
  bool _isDragging = false;
  double _progress = 0;
  int _rotateAngle = 90;

  File? _outputFile;
  String? _downloadUrl;
  String? _outputName;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: widget.tool.allowsMultipleFiles,
      type: FileType.custom,
      allowedExtensions: widget.tool.expectsPdfInput ? ["pdf"] : ["jpg", "jpeg", "png"],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _selectedFiles
        ..clear()
        ..addAll(result.paths.whereType<String>().map(File.new));
      _outputFile = null;
      _downloadUrl = null;
      _outputName = null;
    });
  }

  Future<void> _processFiles() async {
    if (_selectedFiles.isEmpty) {
      _showMessage("Please pick at least one file.", isError: true);
      return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0;
      _outputFile = null;
    });

    try {
      final result = await _apiClient.processFiles(
        tool: widget.tool,
        files: _selectedFiles,
        rotateAngle: _rotateAngle,
        onProgress: (value) {
          if (mounted) {
            setState(() => _progress = value);
          }
        },
      );

      setState(() {
        _downloadUrl = result.downloadUrl;
        _outputName = result.fileName;
      });

      _showMessage("Processing completed.");
    } catch (error) {
      _showMessage("Failed to process file(s): $error", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progress = 0;
        });
      }
    }
  }

  Future<void> _downloadFile() async {
    if (_downloadUrl == null || _outputName == null) {
      _showMessage("Process files first.", isError: true);
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final file = await _apiClient.downloadOutput(
        url: _downloadUrl!,
        fileName: _outputName!,
        onProgress: (value) {
          if (mounted) {
            setState(() => _progress = value);
          }
        },
      );

      setState(() => _outputFile = file);
      _showMessage("Download complete: ${file.path.split("/").last}");
    } catch (error) {
      _showMessage("Download failed: $error", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0;
        });
      }
    }
  }

  void _openOutput() {
    if (_outputFile == null) {
      _showMessage("No downloaded output yet.", isError: true);
      return;
    }

    final ext = _outputFile!.path.toLowerCase();
    if (ext.endsWith(".pdf")) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PdfViewerScreen(file: _outputFile!)),
      );
      return;
    }

    OpenFilex.open(_outputFile!.path);
  }

  Future<void> _shareOutput() async {
    if (_outputFile == null) {
      _showMessage("No file available to share.", isError: true);
      return;
    }

    await Share.shareXFiles([XFile(_outputFile!.path)]);
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Widget _buildPickedFilesPreview() {
    if (_selectedFiles.isEmpty) {
      return const Text("No files selected yet.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedFiles.map((file) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        final isImage = fileName.toLowerCase().endsWith(".jpg") ||
            fileName.toLowerCase().endsWith(".jpeg") ||
            fileName.toLowerCase().endsWith(".png");

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              if (isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(file, width: 46, height: 46, fit: BoxFit.cover),
                )
              else
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.picture_as_pdf),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleDroppedFiles(List<XFile> files) async {
    if (files.isEmpty) {
      return;
    }

    final accepted = <File>[];

    for (final file in files) {
      final path = file.path.toLowerCase();
      if (widget.tool.expectsPdfInput && path.endsWith(".pdf")) {
        accepted.add(File(file.path));
      }
      if (!widget.tool.expectsPdfInput &&
          (path.endsWith(".jpg") || path.endsWith(".jpeg") || path.endsWith(".png"))) {
        accepted.add(File(file.path));
      }
    }

    if (accepted.isEmpty) {
      _showMessage("Dropped files did not match expected type.", isError: true);
      return;
    }

    setState(() {
      if (widget.tool.allowsMultipleFiles) {
        _selectedFiles
          ..clear()
          ..addAll(accepted);
      } else {
        _selectedFiles
          ..clear()
          ..add(accepted.first);
      }
      _outputFile = null;
      _downloadUrl = null;
      _outputName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.tool.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.tool.subtitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isProcessing || _isDownloading ? null : _pickFiles,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Pick File(s)"),
                  ),
                  const SizedBox(height: 10),
                  DropTarget(
                    onDragEntered: (_) => setState(() => _isDragging = true),
                    onDragExited: (_) => setState(() => _isDragging = false),
                    onDragDone: (detail) {
                      setState(() => _isDragging = false);
                      _handleDroppedFiles(detail.files);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _isDragging
                            ? colors.primary.withValues(alpha: 0.12)
                            : colors.primary.withValues(alpha: 0.05),
                        border: Border.all(
                          color: _isDragging
                              ? colors.primary
                              : colors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        "Drag and drop files here",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurface.withValues(alpha: 0.82)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPickedFilesPreview(),
                  if (widget.tool == ToolType.rotate) ...[
                    const SizedBox(height: 8),
                    Text("Rotation Angle", style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 90, label: Text("90")),
                        ButtonSegment(value: 180, label: Text("180")),
                        ButtonSegment(value: 270, label: Text("270")),
                      ],
                      selected: {_rotateAngle},
                      onSelectionChanged: (value) => setState(() => _rotateAngle = value.first),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isProcessing || _isDownloading ? null : _processFiles,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Process"),
                  ),
                  if (_isProcessing || _isDownloading) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: _progress <= 0 ? null : _progress),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Output", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(_outputName ?? "No output generated yet."),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isProcessing || _isDownloading ? null : _downloadFile,
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isProcessing || _isDownloading ? null : _openOutput,
                        icon: const Icon(Icons.visibility),
                        label: const Text("Open"),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isProcessing || _isDownloading ? null : _shareOutput,
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              "Tip: Use split/PDF-to-images outputs as ZIP files. For Android emulator, keep backend on host and use 10.0.2.2 as base URL.",
            ),
          ),
        ],
      ),
    );
  }
}
