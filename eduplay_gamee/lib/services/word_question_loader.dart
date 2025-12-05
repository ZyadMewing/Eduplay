import 'dart:convert';
import 'package:flutter/services.dart';

class WordQuestionLoader {
  static Future<Map<String, dynamic>> loadQuestions() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/word_questions.json',
    );
    return jsonDecode(jsonString);
  }

  static Future<List<List<String>>> getNormalQuestions() async {
    final data = await loadQuestions();
    return List<List<String>>.from(
      (data['normal'] as List).map((item) => List<String>.from(item['words'])),
    );
  }

  static Future<List<List<String>>> getBossQuestions() async {
    final data = await loadQuestions();
    return List<List<String>>.from(
      (data['boss'] as List).map((item) => List<String>.from(item['words'])),
    );
  }
}
