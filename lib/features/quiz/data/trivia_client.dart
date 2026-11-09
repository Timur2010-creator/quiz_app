import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../domain/question.dart';
import '../domain/quiz_config.dart';
import '../domain/trivia_category.dart';

class TriviaException implements Exception {
  const TriviaException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TriviaClient {
  TriviaClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://opentdb.com/',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;
  final Random _random = Random();

  void close() => _dio.close();

  Future<List<TriviaCategory>> loadCategories() async {
    final body = await _getJson('api_category.php');
    final raw = body['trivia_categories'];
    if (raw is! List) {
      throw const TriviaException('The category list has an unexpected format.');
    }
    return raw.map<TriviaCategory>((item) {
      final map = item as Map;
      return TriviaCategory(id: map['id'] as int, name: map['name'] as String);
    }).toList();
  }

  Future<List<Question>> loadQuestions(QuizConfig config) async {
    final query = <String, Object>{
      'amount': config.amount,
      'encode': 'base64',
    };
    if (!config.category.isAny) query['category'] = config.category.id;
    final difficulty = config.difficulty.apiValue;
    if (difficulty != null) query['difficulty'] = difficulty;
    final type = config.format.apiValue;
    if (type != null) query['type'] = type;

    final body = await _getJson('api.php', query: query);
    final code = body['response_code'];
    if (code is! int) {
      throw const TriviaException('The question response has an unexpected format.');
    }
    if (code != 0) throw TriviaException(_messageForCode(code));

    final raw = body['results'];
    if (raw is! List || raw.isEmpty) {
      throw const TriviaException('No questions were returned. Please try again.');
    }
    return raw.map<Question>((item) => _parseQuestion(item as Map)).toList();
  }

  Question _parseQuestion(Map questionData) {
    final correctAnswer = _decode(questionData['correct_answer'] as String);
    final incorrectAnswers = (questionData['incorrect_answers'] as List)
        .map((answer) => _decode(answer as String))
        .toList();

    // A true/false question has exactly one wrong answer.
    final isBoolean = incorrectAnswers.length == 1;
    final List<String> options;
    if (isBoolean) {
      options = ['True', 'False'];
    } else {
      options = [correctAnswer, ...incorrectAnswers]..shuffle(_random);
    }

    final correctIndex = options.indexOf(correctAnswer);
    if (correctIndex < 0) {
      throw const TriviaException('A question had an invalid answer list.');
    }

    return Question(
      category: _decode(questionData['category'] as String),
      text: _decode(questionData['question'] as String),
      kind: isBoolean ? QuestionKind.boolean : QuestionKind.multiple,
      options: options,
      correctIndex: correctIndex,
    );
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, Object>? query,
  }) async {
    try {
      final response = await _dio.get<Object?>(path, queryParameters: query);
      final data = response.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw const TriviaException('The server returned an unexpected response.');
    } on DioException catch (error) {
      throw TriviaException(_describe(error));
    }
  }

  String _decode(String value) => utf8.decode(base64.decode(value));

  String _messageForCode(int code) => switch (code) {
        1 => 'Not enough questions for this selection. Try fewer questions or other options.',
        2 => 'The selected options were rejected. Please change the settings.',
        5 => 'Too many requests. Wait a few seconds and try again.',
        _ => 'The trivia server could not provide questions. Please try again.',
      };

  String _describe(DioException error) => switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'The request timed out. Check your connection and try again.',
        DioExceptionType.connectionError =>
          'No internet connection. Check your network and try again.',
        _ => error.response?.statusCode == 429
            ? 'Too many requests. Wait a few seconds and try again.'
            : 'Could not reach the trivia server. Please try again.',
      };
}
