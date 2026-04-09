import 'dart:convert';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';

class TextDecoder {
  static Future<String> decode(List<int> bytes) async {
    final uint8Bytes = Uint8List.fromList(bytes);

    try {
      // tenta UTF-8 primeiro
      return utf8.decode(uint8Bytes);
    } catch (_) {
      try {
        // fallback para Latin1
        return await CharsetConverter.decode("latin1", uint8Bytes);
      } catch (_) {
        // último fallback
        return String.fromCharCodes(uint8Bytes);
      }
    }
  }
}