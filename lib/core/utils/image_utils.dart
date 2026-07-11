import 'dart:convert';
import 'dart:io';

/// Utilities for handling image files in API calls.
class ImageUtils {
  ImageUtils._();

  /// Reads a local image file and returns its content as a base64 data URI
  /// suitable for DashScope's multimodal API.
  ///
  /// Example output: `data:image/jpeg;base64,/9j/4AAQ...`
  static Future<String> fileToDataUri(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ArgumentError('Image file not found: $filePath');
    }
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);
    final mimeType = _inferMimeType(filePath);
    return 'data:$mimeType;base64,$base64';
  }

  /// Infers MIME type from file extension.
  static String _inferMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg'; // safe default
    }
  }
}
