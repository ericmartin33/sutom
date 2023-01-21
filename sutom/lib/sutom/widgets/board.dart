import 'package:flutter/material.dart';
import '../sutom.dart';

class Board extends StatelessWidget {
  const Board({super.key, required this.board});

  final List<Word> board;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: board
          .map((word) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: word.letters
                    .map((letter) => BoardTile(letter: letter))
                    .toList(),
              ))
          .toList(),
    );
  }
}
