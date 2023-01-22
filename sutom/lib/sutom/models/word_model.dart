import 'package:equatable/equatable.dart';
import 'package:sutom/sutom/sutom.dart';

class Word extends Equatable {
  const Word({required this.letters});

  final List<Letter> letters;

  factory Word.fromString(String word) =>
      Word(letters: word.split('').map((e) => Letter(val: e)).toList());

  String get wordString => letters.map((e) => e.val).join();

  void addLetter(String val) {
    final currentIndex = letters.indexWhere((e) => e.val.isEmpty);
    if (currentIndex != -1) {
      letters[currentIndex] = Letter(val: val);
    }
  }

  void removeLetter() {
    final mostRecentIndex = letters.lastIndexWhere((e) => e.val.isNotEmpty);
    if (mostRecentIndex != -1 && mostRecentIndex > 0) {
      letters[mostRecentIndex] = Letter.empty();
    }
  }

  @override
  List<Object?> get props => [letters];
}
