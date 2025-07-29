import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GabraApiService {
  static const String _baseUrl =
      'https://mlrs.research.um.edu.mt/resources/gabra-api';

  // Cache for API responses to avoid repeated calls
  static final Map<String, dynamic> _cache = {};

  /// Search for a lexeme by lemma
  static Future<Map<String, dynamic>?> searchLexeme(String lemma) async {
    // Check cache first
    if (_cache.containsKey(lemma)) {
      return _cache[lemma];
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/lexemes/search?s=${Uri.encodeComponent(lemma.toLowerCase())}&l=1&wf=0&g=0'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Find exact match for our lemma
        if (data['results'] != null) {
          for (final result in data['results']) {
            final lexeme = result['lexeme'];
            if (lexeme != null &&
                lexeme['lemma']?.toLowerCase() == lemma.toLowerCase()) {
              _cache[lemma] = lexeme;
              return lexeme;
            }
          }
        }
      }
    } catch (e) {
      // Log error silently in production
      debugPrint('Error fetching lexeme data for $lemma: $e');
    }

    return null;
  }

  /// Get detailed lexeme information by ID
  static Future<Map<String, dynamic>?> getLexemeById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lexemes/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching lexeme by ID $id: $e');
    }

    return null;
  }

  /// Get wordforms for a lexeme
  static Future<List<Map<String, dynamic>>> getWordforms(
      String lexemeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lexemes/wordforms/$lexemeId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching wordforms for $lexemeId: $e');
    }

    return [];
  }

  /// Get related lexemes
  static Future<List<Map<String, dynamic>>> getRelatedLexemes(
      String lexemeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lexemes/related/$lexemeId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching related lexemes for $lexemeId: $e');
    }

    return [];
  }
}
