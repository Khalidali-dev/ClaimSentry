import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ParsedDocument {
  final String fileName;
  final int fileSize;
  final String text;
  final int pageCount;
  final bool isPdf;

  const ParsedDocument({
    required this.fileName,
    required this.fileSize,
    required this.text,
    required this.pageCount,
    required this.isPdf,
  });
}

class DocumentParserService {
  /// Opens a file picker for PDF and TXT files, then parses and extracts text.
  static Future<ParsedDocument?> pickAndParseDocument() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'text', 'log'],
      );

      if (files.isEmpty) {
        return null;
      }

      final file = files.first;
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('Selected file has no readable data.');
      }

      final extension = (file.extension ?? '').toLowerCase();
      final isPdf = extension == 'pdf' || _isPdfBytes(bytes);

      if (isPdf) {
        return _parsePdf(file.name, bytes);
      } else {
        return _parseText(file.name, bytes);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Parses text from raw bytes directly (useful for testing or drag-and-drop bytes)
  static ParsedDocument parseBytes({
    required String fileName,
    required Uint8List bytes,
  }) {
    if (bytes.isEmpty) {
      throw Exception('Provided file bytes are empty.');
    }
    final extension = (fileName.contains('.') ? fileName.split('.').last : '').toLowerCase();
    final isPdf = extension == 'pdf' || _isPdfBytes(bytes);

    if (isPdf) {
      return _parsePdf(fileName, bytes);
    } else {
      return _parseText(fileName, bytes);
    }
  }

  /// Parses text from raw bytes of a PDF document
  static ParsedDocument _parsePdf(String fileName, Uint8List bytes) {
    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: bytes);
      final pageCount = document.pages.count;
      final textExtractor = PdfTextExtractor(document);
      String extractedText = textExtractor.extractText();

      extractedText = _cleanText(extractedText);

      // If text extractor returned empty (e.g. image-only PDF), fallback to stream regex
      if (extractedText.trim().isEmpty) {
        extractedText = _fallbackPdfStreamExtract(bytes);
      }

      if (extractedText.trim().isEmpty) {
        extractedText = '[Notice: No selectable text stream found in $fileName. '
            'If this is a scanned document, OCR is recommended. '
            'Please verify or paste the clinical encounter text manually.]';
      }

      return ParsedDocument(
        fileName: fileName,
        fileSize: bytes.length,
        text: extractedText,
        pageCount: pageCount,
        isPdf: true,
      );
    } finally {
      document?.dispose();
    }
  }

  /// Parses text from TXT/plain text files
  static ParsedDocument _parseText(String fileName, Uint8List bytes) {
    String text;
    try {
      text = utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      text = latin1.decode(bytes);
    }

    text = _cleanText(text);

    return ParsedDocument(
      fileName: fileName,
      fileSize: bytes.length,
      text: text,
      pageCount: 1,
      isPdf: false,
    );
  }

  /// Clean up excessive trailing blank lines and formatting artifacts
  static String _cleanText(String raw) {
    return raw
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Check magic bytes for PDF (%PDF-)
  static bool _isPdfBytes(Uint8List bytes) {
    if (bytes.length < 5) return false;
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46 && // F
        bytes[4] == 0x2D; // -
  }

  /// Basic regex fallback for uncompressed text streams in simple PDFs
  static String _fallbackPdfStreamExtract(Uint8List bytes) {
    try {
      final rawStr = latin1.decode(bytes);
      final matches = RegExp(r'\(([^)]+)\)\s*Tj').allMatches(rawStr);
      if (matches.isNotEmpty) {
        final buffer = StringBuffer();
        for (final m in matches) {
          final group = m.group(1);
          if (group != null && group.isNotEmpty) {
            buffer.write('$group ');
          }
        }
        return buffer.toString().trim();
      }
    } catch (_) {}
    return '';
  }
}
