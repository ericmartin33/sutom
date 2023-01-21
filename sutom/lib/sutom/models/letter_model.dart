import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../app/app_colors.dart';

enum LetterStatus {
  initial,
  notInWord,
  inwWord,
  correct,
}

class Letter extends Equatable {
  final String val;
  final LetterStatus status;
  const Letter({required this.val, this.status = LetterStatus.initial});

  factory Letter.empty() => const Letter(val: '');

  Color get backgroundColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.transparent;
      case LetterStatus.notInWord:
        return notInWordColor;
      case LetterStatus.correct:
        return correctColor;
      case LetterStatus.inwWord:
        return inWorldColor;
    }
  }

  Color get borderColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  Letter copyWith({String? val, LetterStatus? status}) {
    return Letter(
      val: val ?? '',
      status: status ?? LetterStatus.initial,
    );
  }

  @override
  List<Object?> get props => [status, val];
}
