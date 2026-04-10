import "dart:io";

import "package:dio/dio.dart";
import "package:docucharm_frontend/core/constants/api_constants.dart";
import "package:docucharm_frontend/features/processor/domain/tool_type.dart";
import "package:path_provider/path_provider.dart";

class UploadInputFile {
  final String fileName;
  final String? filePath;
  final List<int>? bytes;

  const UploadInputFile({
    required this.fileName,
    this.filePath,
    this.bytes,
  });
}

class ProcessResult {
  final String fileName;
  final String downloadUrl;

  const ProcessResult({required this.fileName, required this.downloadUrl});
}

class PdfApiClient {
  PdfApiClient({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  final Dio _dio;

  Future<ProcessResult> processFiles({
    required ToolType tool,
    required List<UploadInputFile> files,
    int? rotateAngle,
    required void Function(double progress) onProgress,
  }) async {
    final formData = FormData();

    if (tool.allowsMultipleFiles) {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            "files",
            await _toMultipartFile(file),
          ),
        );
      }
    } else {
      formData.files.add(
        MapEntry(
          "file",
          await _toMultipartFile(files.first),
        ),
      );
    }

    if (tool == ToolType.rotate) {
      formData.fields.add(MapEntry("angle", (rotateAngle ?? 90).toString()));
    }

    final response = await _dio.post<Map<String, dynamic>>(
      tool.endpoint,
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) {
          onProgress(sent / total);
        }
      },
    );

    final body = response.data ?? {};
    return ProcessResult(
      fileName: (body["fileName"] ?? "output.pdf").toString(),
      downloadUrl: body["downloadUrl"].toString(),
    );
  }

  Future<File> downloadOutput({
    required String url,
    required String fileName,
    required void Function(double progress) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputFile = File("${dir.path}/$fileName");

    await _dio.download(
      url,
      outputFile.path,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    return outputFile;
  }

  Future<MultipartFile> _toMultipartFile(UploadInputFile file) async {
    if (file.filePath != null && file.filePath!.isNotEmpty) {
      return MultipartFile.fromFile(file.filePath!, filename: file.fileName);
    }

    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.fileName);
    }

    throw UnsupportedError("Selected file has no readable path or bytes.");
  }
}
