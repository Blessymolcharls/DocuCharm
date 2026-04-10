import "dart:io";

import "package:dio/dio.dart";
import "package:docucharm_frontend/core/constants/api_constants.dart";
import "package:docucharm_frontend/features/processor/domain/tool_type.dart";
import "package:path_provider/path_provider.dart";

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
    required List<File> files,
    int? rotateAngle,
    required void Function(double progress) onProgress,
  }) async {
    final formData = FormData();

    if (tool.allowsMultipleFiles) {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            "files",
            await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
          ),
        );
      }
    } else {
      formData.files.add(
        MapEntry(
          "file",
          await MultipartFile.fromFile(files.first.path, filename: files.first.uri.pathSegments.last),
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
}
