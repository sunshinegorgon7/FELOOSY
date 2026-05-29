import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelDownloadService {
  static const String modelUrl =
      'https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf';
  static const String modelFileName = 'gemma-2-2b-it-Q4_K_M.gguf';
  // Approximate byte size used for progress when Content-Length is unavailable
  static const int modelSizeBytes = 1_617_362_944;

  static Future<String> modelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${dir.path}/feloosy_models');
    if (!modelsDir.existsSync()) modelsDir.createSync(recursive: true);
    return '${modelsDir.path}/$modelFileName';
  }

  static Future<bool> isReady() async {
    final path = await modelPath();
    return File(path).existsSync();
  }

  /// Streams progress values from 0.0 to 1.0. Resumes partial downloads.
  /// Throws on HTTP or IO error.
  static Stream<double> download() async* {
    final path = await modelPath();
    final partPath = '$path.part';
    final partFile = File(partPath);

    final existingBytes = partFile.existsSync() ? partFile.lengthSync() : 0;

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(modelUrl));
      if (existingBytes > 0) {
        request.headers['Range'] = 'bytes=$existingBytes-';
      }

      final response = await client.send(request);
      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('Download failed: HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      final totalBytes =
          contentLength != null ? existingBytes + contentLength : modelSizeBytes;

      int received = existingBytes;
      final sink = partFile.openWrite(
        mode: existingBytes > 0 ? FileMode.append : FileMode.write,
      );

      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          yield (received / totalBytes).clamp(0.0, 1.0);
        }
      } finally {
        await sink.close();
      }

      // Atomic rename — only happens on full successful download
      await partFile.rename(path);
      yield 1.0;
    } finally {
      client.close();
    }
  }

  static Future<void> deletePartial() async {
    final path = await modelPath();
    final part = File('$path.part');
    if (part.existsSync()) part.deleteSync();
  }

  static Future<void> deleteModel() async {
    final path = await modelPath();
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }
}
