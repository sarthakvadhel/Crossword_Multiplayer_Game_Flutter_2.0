import 'word_model.dart';

class PuzzleModel {
  final String id;
  final String title;
  final int size;
  final List<WordModel> words;

  const PuzzleModel({
    required this.id,
    required this.title,
    required this.size,
    required this.words,
  });
}
